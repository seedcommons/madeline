# InterestCalculator is responsible for running through all Transactions associated with a Loan and:
#   1. Calculating the correct amounts to debit/credit from/to each of the three special accounts
#      for the Loan's division (see below for more on special accounts and the formula
#      for the calculations).
#   2. Creating/updating LineItems in Madeline to match the calculated amounts.
#   3. Syncing those LineItems to Quickbooks.
#   4. Recalculating Transaction balances (see Transaction model for more info on this operation).
#
# Special Accounts
# ====================
# A Madeline Division can be associated with three special Quickbooks accounts:
#   * Principal account
#     * Tracks principal amounts loaned to organizations
#     * Should be an *accounts receivable* account in Quickbooks
#   * Interest receivable account
#     * Tracks interest owed to the loan fund
#     * Should be an *accounts receivable* account in Quickbooks
#   * Interest income account
#     * Tracks income generated from interest on loans by the loan found
#     * Should be an *income* account in Quickbooks
#
# Calculation Formula
# =====================
# For each Madeline transaction, in standard order (see the Transaction model for more on standard order):
#   * For *interest* transactions:
#     * Debit interest receivable account by transaction amount
#     * Credit interest income account by transaction amount
#   * For *disbursements* transactions:
#     * Credit transaction account by transaction amount
#     * Debit principal account by transaction amount
#   * For *repayment* transactions:
#     * Debit transaction account by transaction amount
#     * Credit interest receivable account by the lesser of
#       * transaction amount, and
#       * previous transaction's `interest_balance`
#     * Credit principal account by the greater of:
#       * transaction amount minus previous transaction's `interest_balance`, and
#       * zero
#
module Accounting
  class InterestCalculator
    attr_reader :loan, :prin_acct, :int_rcv_acct, :int_inc_acct

    def initialize(loan)
      @loan = loan
      @prin_acct = qb_division.principal_account
      @int_rcv_acct = qb_division.interest_receivable_account
      @int_inc_acct = qb_division.interest_income_account
    end

    def recalculate
      prev_tx = nil

      loan.transactions.standard_order.each do |tx|
        case tx.loan_transaction_type_value
        when "interest"
          if prev_tx
            accrued_interest = prev_tx.principal_balance * loan.interest_rate / 365 * (tx.txn_date - prev_tx.txn_date)
          else
            accrued_interest = 0
          end

          line_item_for(tx, int_rcv_acct).update!(
            qb_line_id: 0,
            posting_type: "Debit",
            amount: accrued_interest
          )
          line_item_for(tx, int_inc_acct).update!(
            qb_line_id: 1,
            posting_type: "Credit",
            amount: accrued_interest
          )

        when "disbursement"
          line_item_for(tx, prin_acct).update!(
            qb_line_id: 0,
            posting_type: "Debit",
            amount: tx.amount
          )
          line_item_for(tx, tx.account).update!(
            qb_line_id: 1,
            posting_type: "Credit",
            amount: tx.amount
          )

        when "repayment"
          int_part = [tx.amount, prev_tx.try(:interest_balance) || 0].min
          line_item_for(tx, tx.account).update!(
            qb_line_id: 0,
            posting_type: "Debit",
            amount: tx.amount
          )
          line_item_for(tx, prin_acct).update!(
            qb_line_id: 1,
            posting_type: "Credit",
            amount: tx.amount - int_part
          )
          line_item_for(tx, int_rcv_acct).update!(
            qb_line_id: 2,
            posting_type: "Credit",
            amount: int_part
          )
        end

        reconciler = Accounting::Quickbooks::TransactionReconciler.new(qb_division)
        journal_entry = reconciler.reconcile tx

        # It's important we store the ID and type of the QB journal entry we just created
        # so that on the next sync, a duplicate is not created.
        tx.associate_with_qb_obj(journal_entry)

        # Since we may have just adjusted line items upon which the change_in_principal and
        # change_in_interest depend, it is important that we recalculate balances now.
        tx.calculate_balances(prev_tx: prev_tx)
        tx.save!
        prev_tx = tx
      end
    end

    private

    delegate :qb_division, to: :loan

    # Finds or creates line item for transaction and account
    def line_item_for(tx, acct)
      tx.line_item_for(acct) || tx.line_items.build(account: acct)
    end
  end
end
