module Accounting
  class InterestCalculator
    attr_reader :loan, :prin_acct, :int_rcv_acct, :int_inc_acct

    def initialize(loan)
      @loan = loan
      @prin_acct = loan.division.principal_account
      @int_rcv_acct = loan.division.interest_receivable_account
      @int_inc_acct = loan.division.interest_income_account
    end

    def recalculate
      prev_tx = nil

      loan.transactions.standard_order.each do |tx|
        case tx.loan_transaction_type_value
        when "interest"
          line_item_for(tx, int_rcv_acct).update!(
            posting_type: "Debit",
            amount: tx.amount
          )
          line_item_for(tx, int_inc_acct).update!(
            posting_type: "Credit",
            amount: tx.amount
          )

        when "disbursement"
          line_item_for(tx, prin_acct).update!(
            posting_type: "Debit",
            amount: tx.amount
          )
          line_item_for(tx, tx.account).update!(
            posting_type: "Credit",
            amount: tx.amount
          )

        when "repayment"
          int_part = [tx.amount, prev_tx.try(:interest_balance) || 0].min
          line_item_for(tx, tx.account).update!(
            posting_type: "Debit",
            amount: tx.amount
          )
          line_item_for(tx, int_rcv_acct).update!(
            posting_type: "Credit",
            amount: int_part
          )
          line_item_for(tx, prin_acct).update!(
            posting_type: "Credit",
            amount: tx.amount - int_part
          )
        end

        reconciler = Quickbooks::TransactionReconciler.new
        journal_entry = reconciler.reconcile tx

        # It's important we store the ID and type of the QB journal entry we just created
        # so that on the next sync, a duplicate is not created.
        tx.associate_with_qb_obj(journal_entry)

        tx.calculate_balances(prev_tx: prev_tx)
        tx.save!
        prev_tx = tx
      end
    end

    private

    # Finds or creates line item for transaction and account
    def line_item_for(tx, acct)
      tx.line_item_for(acct) || tx.line_items.build(account: acct)
    end
  end
end
