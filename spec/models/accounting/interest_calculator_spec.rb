require 'rails_helper'

describe Accounting::InterestCalculator do
  let!(:division) { create(:division, :with_accounts) }
  let(:loan) { create(:loan, division: division) }
  let!(:t0) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 100.0,
    project: loan, txn_date: Date.today - 3, division: division) }
  let!(:t1) { create(:accounting_transaction, loan_transaction_type_value: "interest", amount: 3.1,
    project: loan, txn_date: Date.today, division: division) }
  let!(:t2) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 17.5,
    project: loan, txn_date: Date.today + 1.day, division: division) }
  let!(:t3) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 12.3,
    project: loan, txn_date: Date.today + 2.days, division: division) }
  let!(:prin_acct) { division.principal_account }
  let!(:int_rcv_acct) { division.interest_receivable_account }
  let!(:int_inc_acct) { division.interest_income_account }

  describe 'initial creation and update' do
    it do
      #########################
      # Initial computation

      Accounting::InterestCalculator.new(loan).recalculate_line_items

      # t0
      # size
      expect(t0.line_items.size).to eq(2)

      # account details
      expect(t0.line_item_for(prin_acct).amount).to be_within(0.0001).of(100)
      expect(t0.line_item_for(prin_acct).posting_type).to eq('debit')
      expect(t0.line_item_for(t0.account).amount).to be_within(0.0001).of(100)
      expect(t0.line_item_for(t0.account).posting_type).to eq('credit')

      # balances
      expect(t0.reload.principal_balance).to be_within(0.0001).of(100)
      expect(t0.reload.interest_balance).to be_within(0.0001).of(0)

      # t1
      # size
      expect(t1.line_items.size).to eq(2)

      # account details
      expect(t1.line_item_for(int_rcv_acct).amount).to be_within(0.0001).of(3.1)
      expect(t1.line_item_for(int_rcv_acct).posting_type).to eq('debit')
      expect(t1.line_item_for(int_inc_acct).amount).to be_within(0.0001).of(3.1)
      expect(t1.line_item_for(int_inc_acct).posting_type).to eq('credit')

      # balances
      expect(t1.reload.principal_balance).to be_within(0.0001).of(100)
      expect(t1.reload.interest_balance).to be_within(0.0001).of(3.1)

      # t2
      # size
      expect(t2.line_items.size).to eq(2)

      # account details
      expect(t2.line_item_for(prin_acct).amount).to be_within(0.0001).of(17.5)
      expect(t2.line_item_for(prin_acct).posting_type).to eq('debit')
      expect(t2.line_item_for(t2.account).amount).to be_within(0.0001).of(17.5)
      expect(t2.line_item_for(t2.account).posting_type).to eq('credit')

      # balances
      expect(t2.reload.principal_balance).to be_within(0.0001).of(117.5)
      expect(t2.reload.interest_balance).to be_within(0.0001).of(3.1)

      # t3
      # size
      expect(t3.line_items.size).to eq(3)

      # account details
      expect(t3.line_item_for(t3.account).amount).to be_within(0.0001).of(12.3)
      expect(t3.line_item_for(t3.account).posting_type).to eq('debit')
      expect(t3.line_item_for(int_rcv_acct).amount).to be_within(0.0001).of(3.1)
      expect(t3.line_item_for(int_rcv_acct).reload.posting_type).to eq('credit')
      expect(t3.line_item_for(prin_acct).amount).to be_within(0.0001).of(9.2)
      expect(t3.line_item_for(prin_acct).posting_type).to eq('credit')

      # balances
      expect(t3.reload.principal_balance).to be_within(0.0001).of(108.3)
      expect(t3.reload.interest_balance).to be_within(0.0001).of(0)

      #########################
      # Recalculation after change

      t1.update!(amount: 2.5)
      Accounting::InterestCalculator.new(loan).recalculate_line_items

      # t2
      # size
      expect(t2.line_items.size).to eq(2)

      # account details
      expect(t2.line_item_for(prin_acct).amount).to be_within(0.0001).of(17.5)
      expect(t2.line_item_for(prin_acct).posting_type).to eq('debit')
      expect(t2.line_item_for(t2.account).amount).to be_within(0.0001).of(17.5)
      expect(t2.line_item_for(t2.account).posting_type).to eq('credit')

      # balances
      expect(t2.reload.principal_balance).to be_within(0.0001).of(117.5)
      expect(t2.reload.interest_balance).to be_within(0.0001).of(2.5)

      # t3
      # size
      expect(t3.line_items.size).to eq(3)

      # account details
      expect(t3.line_item_for(t3.account).amount).to be_within(0.0001).of(12.3)
      expect(t3.line_item_for(t3.account).posting_type).to eq('debit')
      expect(t3.line_item_for(int_rcv_acct).amount).to be_within(0.0001).of(2.5)
      expect(t3.line_item_for(int_rcv_acct).reload.posting_type).to eq('credit')
      expect(t3.line_item_for(prin_acct).amount).to be_within(0.0001).of(9.8)
      expect(t3.line_item_for(prin_acct).posting_type).to eq('credit')

      # balances
      expect(t3.reload.principal_balance).to be_within(0.0001).of(107.7)
      expect(t3.reload.interest_balance).to be_within(0.0001).of(0)
    end
  end
end
