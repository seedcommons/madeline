# InterestCalculator is responsible for running through all Transactions associated with a Loan and:
#   1. Calculating the correct amounts to debit/credit from/to each of the three special accounts
#      for the Loan's division (see below for more on special accounts and the formula
#      for the calculations).
#   2. Creating/updating LineItems in Madeline to match the calculated amounts.
#   3. Creating/updating transactions and line items in Quickbooks to match those in Madeline,
#      including the newly calculated amounts.
#   4. Recalculating Transaction balances (see Transaction model for more info on this operation).
#
# Special Accounts
# ====================
# A Madeline Division with a Quickbooks connection can be associated with three special Quickbooks accounts:
#   * Principal account
#     * Tracks principal amounts loaned to organizations
#     * Should be an *accounts receivable* account in Quickbooks
#   * Interest receivable account
#     * Tracks interest owed to the loan fund
#     * Should be an *accounts receivable* account in Quickbooks
#   * Interest income account
#     * Tracks income generated from interest on loans by the loan fund
#     * Should be an *income* account in Quickbooks
#
# Each disbursement or repayment transaction is also associated with an account. This represents the
# bank account (or cash) the money is coming out of or going into.
#
# Calculation Formula
# =====================
# For each Madeline transaction, in standard order (see the Transaction model for more on standard order):
#   * For *interest* transactions:
#     * Debit interest receivable account by accrued interest (see below)
#     * Credit interest income account by accrued interest (see below)
#   * For *disbursement* transactions:
#     * Credit transaction account (bank account) by transaction amount
#     * Debit principal account by transaction amount
#   * For *repayment* transactions:
#     * By default, repayments are applied to the interest balance until it reaches zero, then the
#       remainder is applied to the principal.
#     * Debit transaction account (bank account) by transaction amount
#     * Credit interest receivable account by the lesser of
#       * transaction amount, and
#       * previous transaction's `interest_balance`
#     * Credit principal account by the greater of:
#       * transaction amount minus previous transaction's `interest_balance`, and
#       * zero
# Accrued interest formula:
#   No compounding interest! Interest only accrues on principal balance:
#   accrued interest = previous txn's principal balance * interest rate / 365 * # days since previous txn
#
module Accounting
  class InterestCalculator
    attr_reader :loan, :prin_acct, :int_rcv_acct, :int_inc_acct

    def initialize(loan)
      @loan = loan
      @prin_acct = qb_division.principal_account
      @int_rcv_acct = qb_division.interest_receivable_account
      @int_inc_acct = qb_division.interest_income_account
      @closed_books_date = qb_division.closed_books_date || Date.parse("1900-01-01") # default, since not reqd in accounting settings
    end

    def recalculate
      # check if a generic non-interest, managed txn for this loan can be written
      return unless TransactionPolicy.new(:machine, Transaction.new(project: @loan, managed: true)).create?
      return if transactions.empty?

      prev_tx = nil

      txns_by_date = transactions.group_by(&:txn_date)
      first_date = transactions.first&.txn_date
      last_date = loan.status_value == "active" ? Time.zone.today : transactions.last&.txn_date

      txn_dates = txns_by_date.keys
      last_day_in_months = month_boundaries(first_date, last_date)

      dates = txn_dates.concat(last_day_in_months).uniq.sort

      @transactions = []

      dates.each do |date|
        log_data = {loan_id: loan.id, date: date}
        Rails.logger.debug("Recalculating for date #{log_data}")

        # Inserts interest transactions at points in the array where they are needed but missing.
        # There should be one interest transaction on each date for which there are any other
        # transactions, except the date of the first transaction.
        txns = []

        # this adds an interest transaction
        # int txns should always be managed (for now)
        txns << loan.transactions.build(
          txn_date: date,
          amount: 0, # Will be updated momentarily.
          loan_transaction_type_value: Transaction::LOAN_INTEREST_TYPE,
          currency_id: loan.currency_id,
          description: I18n.t("transactions.interest_description", loan_id: loan.id),
          managed: true
        ) if add_int_tx?(txns_by_date[date], prev_tx, loan)

        txns.concat(txns_by_date[date]) if txns_by_date[date]

        txns.each do |tx|
          if tx.managed?
            case tx.loan_transaction_type_value
            when "interest"
              update_interest_txn(prev_tx, tx, int_rcv_acct)
            when "disbursement"
              # this is where disbursements newly created in Madeline get their line items set up
              update_disbursement_txn(tx, prin_acct)
            when "repayment"
              update_repayment_txn(tx, prev_tx, prin_acct, int_rcv_acct)
            end

            if changed?(tx) && tx.txn_date <= @closed_books_date
              record_and_rollback_changes(tx)
            else
              # Since we may have just adjusted line items upon which the change_in_principal and
              # change_in_interest depend, it is important that we recalculate balances now.
              tx.calculate_balances(prev_tx: prev_tx)
            end

            # Before we save, check if the transaction's line items have changed and
            # set the needs_qb_push flag. We ignore changes to the transaction's balances since these
            # don't need to get pushed. Therefore we don't need to check changes on the transaction
            # object itself, just the line items.
            #
            # Note that if the flag is already set we leave it as true even if no changes
            # occurred. The transaction may have changed earlier (e.g. via the UI) and may need a push
            # even if we don't change anything here.
            tx.needs_qb_push = tx.needs_qb_push || tx.line_items.any?(&:type_or_amt_changed?)

            # This should save the transaction and all its line items.
            tx.save!

            # Create/update the transaction in quickbooks if necessary.
            reconciler.reconcile(tx)
          else
            tx.calculate_balances(prev_tx: prev_tx)
            tx.save!
          end

          prev_tx = tx
        end
        @transactions.concat(txns)
      end
    end

    private

    delegate :qb_division, to: :loan

    def record_and_rollback_changes(txn)
      ::Accounting::SyncIssue.create(loan: loan, accounting_transaction: txn, message: :attempted_change_before_closed_books_date, custom_data: {cbd: @closed_books_date, txn_date: txn.txn_date}, level: :warning)
      new_line_items = txn.line_items.select(&:new_record?)
      new_line_items.each { |li| txn.line_items.delete(li) }
      txn.line_items.each(&:restore_attributes)
      txn.restore_attributes
    end

    def changed?(txn)
      txn.changed? || txn.line_items.any?(&:type_or_amt_changed?)
    end

    def update_interest_txn(prev_txn, txn, int_rcv_acct)
      txn.amount = accrued_interest(prev_txn, txn)
      line_item_for(txn, int_rcv_acct).assign_attributes(
        qb_line_id: 0,
        posting_type: "Debit",
        amount: txn.amount
      )
      line_item_for(txn, int_inc_acct).assign_attributes(
        qb_line_id: 1,
        posting_type: "Credit",
        amount: txn.amount
      )
    end

    def update_disbursement_txn(txn, prin_acct)
      line_item_for(txn, prin_acct).assign_attributes(
        qb_line_id: 1,
        posting_type: "Debit",
        amount: txn.amount
      )
      line_item_for(txn, txn.account).assign_attributes(
        # no qb line id bc this li will not be created in qb
        posting_type: "Credit",
        amount: txn.amount
      )
    end

    def update_repayment_txn(txn, prev_txn, prin_acct, int_rcv_acct)
      int_part = [txn.amount, prev_txn.try(:interest_balance) || 0].min
      line_item_for(txn, txn.account).assign_attributes(
        qb_line_id: 0,
        posting_type: "Debit",
        amount: txn.amount
      )
      line_item_for(txn, prin_acct).assign_attributes(
        qb_line_id: 1,
        posting_type: "Credit",
        amount: txn.amount - int_part
      )
      line_item_for(txn, int_rcv_acct).assign_attributes(
        qb_line_id: 2,
        posting_type: "Credit",
        amount: int_part
      )
    end

    def transactions
      @transactions ||= loan.transactions.standard_order.to_a
    end

    def reconciler
      @reconciler ||= Accounting::QB::TransactionReconciler.new(qb_division)
    end

    # Calculates the interest accrued between the date of the last transaction and the current one.
    def accrued_interest(prev_tx, tx)
      if prev_tx
        # Note: QB doesn't accept fractions of pennies
        (prev_tx.principal_balance * daily_rate * (tx.txn_date - prev_tx.txn_date)).round(2)
      else
        0.0
      end
    end

    def daily_rate
      @daily_rate ||= loan.interest_rate / 365.0
    end

    # Finds or creates line item for transaction and account.
    # Guarantees that the LineItem object returned will be in `tx`s `line_items` array (not a separate copy).
    def line_item_for(tx, acct)
      tx.line_item_for(acct) || tx.line_items.build(account: acct, description: tx.description)
    end

    # Get the month boundaries between two dates
    def month_boundaries(d1, d2)
      (d1..d2).select { |d| d == d.end_of_month }
    end

    def add_int_tx?(txs, prev_tx, loan)
      return false if loan.no_interest_rate?

      if txs.nil? # this is an end of month day with no txns
        if prev_tx.txn_date > @closed_books_date
          return true
        else
          ::Accounting::SyncIssue.create(loan: prev_tx.project, accounting_transaction: prev_tx, message: :no_end_of_month_int_txn_before_closed_books_date, custom_data: {cbd: @closed_books_date, txn_date: prev_tx.txn_date}, level: :warning)
        end
      elsif prev_tx && prev_tx.principal_balance > 0 && txs.none?(&:interest?)
        if prev_tx.txn_date > @closed_books_date
          return true
        else
          ::Accounting::SyncIssue.create(loan: loan, accounting_transaction: prev_tx, message: :attempted_new_int_txn_before_closed_books_date, custom_data: {cbd: @closed_books_date, txn_date: prev_tx.txn_date}, level: :warning)
        end
      end
      false
    end
  end
end
