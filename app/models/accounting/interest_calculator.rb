module Accounting
  class InterestCalculator
    attr_reader :loan, :prin_acct, :int_rcv_acct, :int_inc_acct

    def initialize(loan)
      @loan = loan
      @prin_acct = division.principal_account
      @int_rcv_acct = division.interest_receivable_account
      @int_inc_acct = division.interest_income_account
    end

    def recalculate_line_items
      prev_tx = nil

      loan.transactions.standard_order.each do |tx|
        case tx.loan_transaction_type_value
        when "interest"
          line_item_for(tx, int_rcv_acct).update!(
            posting_type: "debit",
            amount: tx.amount
          )
          line_item_for(tx, int_inc_acct).update!(
            posting_type: "credit",
            amount: tx.amount
          )

        when "disbursement"
          line_item_for(tx, prin_acct).update!(
            posting_type: "debit",
            amount: tx.amount
          )
          line_item_for(tx, tx.account).update!(
            posting_type: "credit",
            amount: tx.amount
          )

        when "repayment"
          int_part = [tx.amount, prev_tx.try(:interest_balance) || 0].min
          line_item_for(tx, tx.account).update!(
            posting_type: "debit",
            amount: tx.amount
          )
          line_item_for(tx, int_rcv_acct).update!(
            posting_type: "credit",
            amount: int_part
          )
          line_item_for(tx, prin_acct).update!(
            posting_type: "credit",
            amount: tx.amount - int_part
          )
        end

        tx.calculate_balances(prev_tx: prev_tx)
        tx.save!
        prev_tx = tx
      end
    end

    private

    delegate :division, to: :loan

    # Finds or creates line item for transaction or account
    def line_item_for(tx, acct)
      tx.line_item_for(acct) || tx.line_items.build(account: acct)
    end
  end
end
