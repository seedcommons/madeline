require 'rails_helper'

# See docs/example_calculation.xlsx for ground truth used to build this spec.
describe Accounting::InterestCalculator do
  let!(:division) { create(:division, :with_accounts) }
  let(:loan) { create(:loan, division: division, rate: 8.0) }
  let!(:t0) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 100.0,
    project: loan, txn_date: "2017-01-01", division: division) }
  let!(:t1) { create(:accounting_transaction, loan_transaction_type_value: "interest", amount: nil,
    project: loan, txn_date: "2017-01-04", division: division) }
  let!(:t2) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 17.50,
    project: loan, txn_date: "2017-01-04", division: division) }
  let!(:t3) { create(:accounting_transaction, loan_transaction_type_value: "interest", amount: nil,
    project: loan, txn_date: "2017-04-01", division: division) }
  let!(:t4) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 1.00,
    project: loan, txn_date: "2017-04-01", division: division) }
  let!(:t5) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 12.30,
    project: loan, txn_date: Date.today + 2.days, division: division) }
  let!(:prin_acct) { division.principal_account }
  let!(:int_rcv_acct) { division.interest_receivable_account }
  let!(:int_inc_acct) { division.interest_income_account }

  describe 'initial creation and update' do
    it do
      #########################
      # Initial computation
      stubbed_calculator.recalculate

      # t0
      # size
      expect(t0.line_items.size).to eq(2)

      # account details
      expect(t0.line_item_for(prin_acct).amount).to equal_money(100.00)
      expect(t0.line_item_for(prin_acct).posting_type).to eq('Debit')
      expect(t0.line_item_for(t0.account).amount).to equal_money(100.00)
      expect(t0.line_item_for(t0.account).posting_type).to eq('Credit')

      # balances
      expect(t0.reload.principal_balance).to equal_money(100.00)
      expect(t0.reload.interest_balance).to equal_money(0)

      # t1
      # size
      expect(t1.line_items.size).to eq(2)

      # account details
      expect(t1.line_item_for(int_rcv_acct).amount).to equal_money(0.07)
      expect(t1.line_item_for(int_rcv_acct).posting_type).to eq('Debit')
      expect(t1.line_item_for(int_inc_acct).amount).to equal_money(0.07)
      expect(t1.line_item_for(int_inc_acct).posting_type).to eq('Credit')

      # balances
      expect(t1.reload.principal_balance).to equal_money(100.00)
      expect(t1.reload.interest_balance).to equal_money(0.07)

      # t2
      # size
      expect(t2.line_items.size).to eq(2)

      # account details
      expect(t2.line_item_for(prin_acct).amount).to equal_money(17.50)
      expect(t2.line_item_for(prin_acct).posting_type).to eq('Debit')
      expect(t2.line_item_for(t2.account).amount).to equal_money(17.50)
      expect(t2.line_item_for(t2.account).posting_type).to eq('Credit')

      # balances
      expect(t2.reload.principal_balance).to equal_money(117.50)
      expect(t2.reload.interest_balance).to equal_money(0.07)

      # t3
      # size
      expect(t3.line_items.size).to eq(2)

      # account details
      expect(t3.line_item_for(int_rcv_acct).amount).to equal_money(2.24)
      expect(t3.line_item_for(int_rcv_acct).posting_type).to eq('Debit')
      expect(t3.line_item_for(int_inc_acct).amount).to equal_money(2.24)
      expect(t3.line_item_for(int_inc_acct).posting_type).to eq('Credit')

      # balances
      expect(t3.reload.principal_balance).to equal_money(117.50)
      expect(t3.reload.interest_balance).to equal_money(2.31)

      # t4
      # size
      expect(t4.line_items.size).to eq(3)

      # account details
      expect(t4.line_item_for(t4.account).amount).to equal_money(1.00)
      expect(t4.line_item_for(t4.account).posting_type).to eq('Debit')
      expect(t4.line_item_for(int_rcv_acct).amount).to equal_money(1.00)
      expect(t4.line_item_for(int_rcv_acct).reload.posting_type).to eq('Credit')
      expect(t4.line_item_for(prin_acct).amount).to equal_money(0.00)
      expect(t4.line_item_for(prin_acct).posting_type).to eq('Credit')

      # balances
      expect(t4.reload.principal_balance).to equal_money(117.50)
      expect(t4.reload.interest_balance).to equal_money(1.31)

      # t5
      # size
      expect(t5.line_items.size).to eq(3)

      # account details
      expect(t5.line_item_for(t5.account).amount).to equal_money(12.30)
      expect(t5.line_item_for(t5.account).posting_type).to eq('Debit')
      expect(t5.line_item_for(int_rcv_acct).amount).to equal_money(1.31)
      expect(t5.line_item_for(int_rcv_acct).reload.posting_type).to eq('Credit')
      expect(t5.line_item_for(prin_acct).amount).to equal_money(10.99)
      expect(t5.line_item_for(prin_acct).posting_type).to eq('Credit')

      # balances
      expect(t5.reload.principal_balance).to equal_money(106.51)
      expect(t5.reload.interest_balance).to equal_money(0.00)

      ##############################################################################################
      # Recalculation after change of second disbursement to larger number

      t2.update!(amount: 52.50)
      stubbed_calculator.recalculate

      # t0
      # size
      expect(t0.line_items.size).to eq(2)

      # account details
      expect(t0.line_item_for(prin_acct).amount).to equal_money(100.00)
      expect(t0.line_item_for(prin_acct).posting_type).to eq('Debit')
      expect(t0.line_item_for(t0.account).amount).to equal_money(100.00)
      expect(t0.line_item_for(t0.account).posting_type).to eq('Credit')

      # balances
      expect(t0.reload.principal_balance).to equal_money(100.00)
      expect(t0.reload.interest_balance).to equal_money(0)

      # t1
      # size
      expect(t1.line_items.size).to eq(2)

      # account details
      expect(t1.line_item_for(int_rcv_acct).amount).to equal_money(0.07)
      expect(t1.line_item_for(int_rcv_acct).posting_type).to eq('Debit')
      expect(t1.line_item_for(int_inc_acct).amount).to equal_money(0.07)
      expect(t1.line_item_for(int_inc_acct).posting_type).to eq('Credit')

      # balances
      expect(t1.reload.principal_balance).to equal_money(100.00)
      expect(t1.reload.interest_balance).to equal_money(0.07)

      # t2
      # size
      expect(t2.line_items.size).to eq(2)

      # account details
      expect(t2.line_item_for(prin_acct).amount).to equal_money(52.50)
      expect(t2.line_item_for(prin_acct).posting_type).to eq('Debit')
      expect(t2.line_item_for(t2.account).amount).to equal_money(52.50)
      expect(t2.line_item_for(t2.account).posting_type).to eq('Credit')

      # balances
      expect(t2.reload.principal_balance).to equal_money(152.50)
      expect(t2.reload.interest_balance).to equal_money(0.07)

      # t3
      # size
      expect(t3.line_items.size).to eq(2)

      # account details
      expect(t3.line_item_for(int_rcv_acct).amount).to equal_money(2.91)
      expect(t3.line_item_for(int_rcv_acct).posting_type).to eq('Debit')
      expect(t3.line_item_for(int_inc_acct).amount).to equal_money(2.91)
      expect(t3.line_item_for(int_inc_acct).posting_type).to eq('Credit')

      # balances
      expect(t3.reload.principal_balance).to equal_money(152.50)
      expect(t3.reload.interest_balance).to equal_money(2.98)

      # t4
      # size
      expect(t4.line_items.size).to eq(3)

      # account details
      expect(t4.line_item_for(t4.account).amount).to equal_money(1.00)
      expect(t4.line_item_for(t4.account).posting_type).to eq('Debit')
      expect(t4.line_item_for(int_rcv_acct).amount).to equal_money(1.00)
      expect(t4.line_item_for(int_rcv_acct).reload.posting_type).to eq('Credit')
      expect(t4.line_item_for(prin_acct).amount).to equal_money(0.00)
      expect(t4.line_item_for(prin_acct).posting_type).to eq('Credit')

      # balances
      expect(t4.reload.principal_balance).to equal_money(152.50)
      expect(t4.reload.interest_balance).to equal_money(1.98)

      # t5
      # size
      expect(t5.line_items.size).to eq(3)

      # account details
      expect(t5.line_item_for(t5.account).amount).to equal_money(12.30)
      expect(t5.line_item_for(t5.account).posting_type).to eq('Debit')
      expect(t5.line_item_for(int_rcv_acct).amount).to equal_money(1.98)
      expect(t5.line_item_for(int_rcv_acct).reload.posting_type).to eq('Credit')
      expect(t5.line_item_for(prin_acct).amount).to equal_money(10.32)
      expect(t5.line_item_for(prin_acct).posting_type).to eq('Credit')

      # balances
      expect(t5.reload.principal_balance).to equal_money(142.18)
      expect(t5.reload.interest_balance).to equal_money(0.00)
    end
  end

  # We have to stub reconciler because it triggers calls to API.
  # We also have to stub associate_with_qb_obj because it depends on the result of reconciler.
  # We deliberately aren't memoizing this because we want a fresh calculator each time, as
  # that best simulates real behavior.
  def stubbed_calculator
    calculator = Accounting::InterestCalculator.new(loan)
    reconciler = double()
    allow(calculator).to receive(:reconciler).and_return(reconciler)
    calculator.send(:transactions).each do |t|
      expect(reconciler).to receive(:reconcile).with(t).and_return(nil)
      expect(t).to receive(:associate_with_qb_obj).with(nil).and_return(nil)
    end
    calculator
  end
end
