require 'rails_helper'

describe Accounting::InterestCalculator do
  let!(:division) { create(:division, :with_accounts) }
  let(:loan) { create(:loan, division: division) }
  let!(:t0) { create(:accounting_transaction, :with_disbursement, project: loan,
    txn_date: Date.today - 3, division: division) }
  let!(:t1) { create(:accounting_transaction, :with_interest, project: loan,
    txn_date: Date.today, division: division) }
  let!(:t2) { create(:accounting_transaction, :with_disbursement, project: loan,
    txn_date: Date.today + 1.day, division: division) }
  let!(:t3) { create(:accounting_transaction, :with_repayment, project: loan,
    txn_date: Date.today + 2.days, division: division) }
  let!(:prin_acct) { division.principal_account }
  let!(:int_rcv_acct) { division.interest_receivable_account }
  let!(:int_inc_acct) { division.interest_income_account }

  context 'existing prior transaction' do

    describe 'after editing disbursement' do
      it 'updates the correct data' do
        # can't update amount because this is a txn and we're testing for line items
        # which are created in the factories
        t2.amount = 10
        t2.save!

        Accounting::InterestCalculator.new.recalculate_line_item(loan)
        loan.reload

        # t0
        # size
        expect(t0.line_items.size).to eq(2)

        # account details
        expect(t0.line_item_for(prin_acct).amount).to eq(100)
        expect(t0.line_item_for(prin_acct).posting_type).to eq('debit')
        expect(t0.line_item_for(t0.account).amount).to eq(100)
        expect(t0.line_item_for(t0.account).posting_type).to eq('credit')

        # balances
        expect(t0.reload.principal_balance).to eq(100)
        expect(t0.reload.interest_balance).to eq(0)

        # t1
        # size
        expect(t1.line_items.size).to eq(2)

        # account details
        expect(t1.line_item_for(int_rcv_acct).amount).to eq(3)
        expect(t1.line_item_for(int_rcv_acct).posting_type).to eq('debit')
        expect(t1.line_item_for(int_inc_acct).amount).to eq(3)
        expect(t1.line_item_for(int_inc_acct).posting_type).to eq('credit')

        # balances
        expect(t1.reload.principal_balance).to eq(100)
        expect(t1.reload.interest_balance).to eq(3)

        # t2
        # size
        expect(t2.line_items.size).to eq(2)

        # account details
        expect(t2.line_item_for(prin_acct).amount).to eq(100)
        expect(t2.line_item_for(prin_acct).posting_type).to eq('debit')
        expect(t2.line_item_for(t2.account).amount).to eq(100)
        expect(t2.line_item_for(t2.account).posting_type).to eq('credit')

        # balances
        expect(t2.reload.principal_balance).to eq(200)
        expect(t2.reload.interest_balance).to eq(3)

        # t3
        # size
        expect(t3.line_items.size).to eq(3)

        # account details
        expect(t3.line_item_for(t3.account).amount).to eq(23.7)
        expect(t3.line_item_for(t3.account).posting_type).to eq('debit')
        expect(t3.line_item_for(int_rcv_acct).amount).to eq(3)
        # line_item_for method is returning the wrong item so calculations are wrong
        expect(t3.line_item_for(int_rcv_acct).reload.posting_type).to eq('credit')
        expect(t3.line_item_for(prin_acct).amount).to eq(20.7)
        expect(t3.line_item_for(prin_acct).posting_type).to eq('credit')

        # balances
        expect(t3.reload.principal_balance).to eq(179.3)
        expect(t3.reload.interest_balance).to eq(0)
      end
    end
  end
end
