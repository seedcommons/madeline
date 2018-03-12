require 'rails_helper'

# See docs/example_calculation.xlsx for ground truth used to build this spec.
describe Accounting::InterestCalculator do
  let!(:division) { create(:division, :with_accounts) }
  let(:loan) { create(:loan, :active, division: division, rate: 8.0) }

  describe 'general operation' do
    let!(:t0) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 100.0,
      project: loan, txn_date: "2017-01-01", division: division) }
    let!(:t1) { create(:accounting_transaction, loan_transaction_type_value: "interest", amount: nil,
      project: loan, txn_date: "2017-01-04", division: division) }
    let!(:t2) { create(:accounting_transaction, loan_transaction_type_value: "disbursement",
      amount: 17.50, project: loan, txn_date: "2017-01-04", division: division) }
    let!(:t3) { create(:accounting_transaction, loan_transaction_type_value: "interest", amount: nil,
      project: loan, txn_date: "2017-01-31", division: division) }
    let!(:t4) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 0.50,
      project: loan, txn_date: "2017-01-31", division: division) }
    let!(:t5) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 12.30,
      project: loan, txn_date: "2017-01-31", division: division) }
    let!(:t6) { create(:accounting_transaction, :unmanaged, :repayment_with_line_items,
      loan_transaction_type_value: "repayment", project: loan, txn_date: "2017-01-31", division: division) }
    let(:all_txns) { [t0, t1, t2, t3, t4, t5, t6] }
    let!(:prin_acct) { division.principal_account }
    let!(:int_rcv_acct) { division.interest_receivable_account }
    let!(:int_inc_acct) { division.interest_income_account }

    describe 'initial creation and update' do
      it do
        #########################
        # Initial computation
        recalculate_and_reload

        # All transactions except t6 should get their push flags set because they didn't have any line items before.
        # t6 is not managed
        expect(all_txns.map(&:needs_qb_push)).to eq [true, true, true, true, true, true, false]

        # t0 --------------------------------------------------------
        expect(t0.line_items.size).to eq(2)

        # account details
        expect(t0.line_item_for(prin_acct).amount).to equal_money(100.00)
        expect(t0.line_item_for(prin_acct).posting_type).to eq('Debit')
        expect(t0.line_item_for(t0.account).amount).to equal_money(100.00)
        expect(t0.line_item_for(t0.account).posting_type).to eq('Credit')

        # balances
        expect(t0.reload.principal_balance).to equal_money(100.00)
        expect(t0.reload.interest_balance).to equal_money(0)

        # t1 --------------------------------------------------------
        expect(t1.line_items.size).to eq(2)

        # account details
        expect(t1.line_item_for(int_rcv_acct).amount).to equal_money(0.07)
        expect(t1.line_item_for(int_rcv_acct).posting_type).to eq('Debit')
        expect(t1.line_item_for(int_inc_acct).amount).to equal_money(0.07)
        expect(t1.line_item_for(int_inc_acct).posting_type).to eq('Credit')

        # balances
        expect(t1.reload.principal_balance).to equal_money(100.00)
        expect(t1.reload.interest_balance).to equal_money(0.07)

        # t2 --------------------------------------------------------
        expect(t2.line_items.size).to eq(2)

        # account details
        expect(t2.line_item_for(prin_acct).amount).to equal_money(17.50)
        expect(t2.line_item_for(prin_acct).posting_type).to eq('Debit')
        expect(t2.line_item_for(t2.account).amount).to equal_money(17.50)
        expect(t2.line_item_for(t2.account).posting_type).to eq('Credit')

        # balances
        expect(t2.reload.principal_balance).to equal_money(117.50)
        expect(t2.reload.interest_balance).to equal_money(0.07)

        # t3 --------------------------------------------------------
        expect(t3.line_items.size).to eq(2)

        # account details
        expect(t3.line_item_for(int_rcv_acct).amount).to equal_money(0.70)
        expect(t3.line_item_for(int_rcv_acct).posting_type).to eq('Debit')
        expect(t3.line_item_for(int_inc_acct).amount).to equal_money(0.70)
        expect(t3.line_item_for(int_inc_acct).posting_type).to eq('Credit')

        # balances
        expect(t3.reload.principal_balance).to equal_money(117.50)
        expect(t3.reload.interest_balance).to equal_money (0.77) # 0.70 + 0.07

        # t4 --------------------------------------------------------
        expect(t4.line_items.size).to eq(3)

        # account details
        expect(t4.line_item_for(t4.account).amount).to equal_money(0.50)
        expect(t4.line_item_for(t4.account).posting_type).to eq('Debit')
        expect(t4.line_item_for(int_rcv_acct).amount).to equal_money(0.50)
        expect(t4.line_item_for(int_rcv_acct).reload.posting_type).to eq('Credit')
        expect(t4.line_item_for(prin_acct).amount).to equal_money(0.0)
        expect(t4.line_item_for(prin_acct).posting_type).to eq('Credit')

        # balances
        expect(t4.reload.principal_balance).to equal_money(117.50)
        expect(t4.reload.interest_balance).to equal_money(0.27) # 0.77 - 0.50

        # t5 --------------------------------------------------------
        expect(t5.line_items.size).to eq(3)

        # account details
        expect(t5.line_item_for(t5.account).amount).to equal_money(12.30)
        expect(t5.line_item_for(t5.account).posting_type).to eq('Debit')
        expect(t5.line_item_for(int_rcv_acct).amount).to equal_money(0.27)
        expect(t5.line_item_for(int_rcv_acct).reload.posting_type).to eq('Credit')
        expect(t5.line_item_for(prin_acct).amount).to equal_money(12.03)
        expect(t5.line_item_for(prin_acct).posting_type).to eq('Credit')

        # balances
        expect(t5.reload.principal_balance).to equal_money(105.47) # 117.50 - 12.03
        expect(t5.reload.interest_balance).to equal_money(0.00)

        # t6 --------------------------------------------------------
        expect(t6.line_items.size).to eq(3)

        # account details
        expect(t6.line_item_for(t6.account).amount).to equal_money(23.7)
        expect(t6.line_item_for(t6.account).posting_type).to eq('Debit')
        expect(t6.line_item_for(int_rcv_acct).amount).to equal_money(11.85)
        expect(t6.line_item_for(int_rcv_acct).posting_type).to eq('Credit')
        expect(t6.line_item_for(prin_acct).amount).to equal_money(11.85)
        expect(t6.line_item_for(prin_acct).posting_type).to eq('Credit')

        # balances
        expect(t6.reload.principal_balance).to equal_money(93.62) # 105.47 - 11.85
        expect(t6.reload.interest_balance).to equal_money(-11.85)


        ##############################################################################################
        # Recalculation after change of second disbursement to larger number

        t2.update!(amount: 52.50)
        recalculate_and_reload

        # t0 --------------------------------------------------------
        expect(t0.line_items.size).to eq(2)

        # This txn is before changed one, so no changes.
        expect(t0.needs_qb_push).to be false

        # account details
        expect(t0.line_item_for(prin_acct).amount).to equal_money(100.00)
        expect(t0.line_item_for(prin_acct).posting_type).to eq('Debit')
        expect(t0.line_item_for(t0.account).amount).to equal_money(100.00)
        expect(t0.line_item_for(t0.account).posting_type).to eq('Credit')

        # balances
        expect(t0.reload.principal_balance).to equal_money(100.00)
        expect(t0.reload.interest_balance).to equal_money(0)

        # t1 --------------------------------------------------------
        expect(t1.line_items.size).to eq(2)

        # This txn is before changed one, so no changes.
        expect(t1.needs_qb_push).to be false

        # account details
        expect(t1.line_item_for(int_rcv_acct).amount).to equal_money(0.07)
        expect(t1.line_item_for(int_rcv_acct).posting_type).to eq('Debit')
        expect(t1.line_item_for(int_inc_acct).amount).to equal_money(0.07)
        expect(t1.line_item_for(int_inc_acct).posting_type).to eq('Credit')

        # balances
        expect(t1.reload.principal_balance).to equal_money(100.00)
        expect(t1.reload.interest_balance).to equal_money(0.07)

        # t2 --------------------------------------------------------
        expect(t2.line_items.size).to eq(2)

        # This is the changed txn
        expect(t2.needs_qb_push).to be true

        # account details
        expect(t2.line_item_for(prin_acct).amount).to equal_money(52.50)
        expect(t2.line_item_for(prin_acct).posting_type).to eq('Debit')
        expect(t2.line_item_for(t2.account).amount).to equal_money(52.50)
        expect(t2.line_item_for(t2.account).posting_type).to eq('Credit')

        # balances
        expect(t2.reload.principal_balance).to equal_money(152.50)
        expect(t2.reload.interest_balance).to equal_money(0.07)

        # t3 --------------------------------------------------------
        expect(t3.line_items.size).to eq(2)

        # This is an interest txn that changes as a result of previous txn change.
        expect(t3.needs_qb_push).to be true

        # account details
        expect(t3.line_item_for(int_rcv_acct).amount).to equal_money(0.90)
        expect(t3.line_item_for(int_rcv_acct).posting_type).to eq('Debit')
        expect(t3.line_item_for(int_inc_acct).amount).to equal_money(0.90)
        expect(t3.line_item_for(int_inc_acct).posting_type).to eq('Credit')

        # balances
        expect(t3.reload.principal_balance).to equal_money(152.50)
        expect(t3.reload.interest_balance).to equal_money (0.97)

        # t4 --------------------------------------------------------
        expect(t4.line_items.size).to eq(3)

        # The line items here stay the same so no need to push.
        expect(t0.needs_qb_push).to be false

        # account details
        expect(t4.line_item_for(t4.account).amount).to equal_money(0.50)
        expect(t4.line_item_for(t4.account).posting_type).to eq('Debit')
        expect(t4.line_item_for(int_rcv_acct).amount).to equal_money(0.50)
        expect(t4.line_item_for(int_rcv_acct).reload.posting_type).to eq('Credit')
        expect(t4.line_item_for(prin_acct).amount).to equal_money(0.00)
        expect(t4.line_item_for(prin_acct).posting_type).to eq('Credit')

        # balances
        expect(t4.reload.principal_balance).to equal_money(152.50)
        expect(t4.reload.interest_balance).to equal_money(0.47) # 0.97 - 0.50

        # t5 --------------------------------------------------------
        expect(t5.line_items.size).to eq(3)

        # account details
        expect(t5.line_item_for(t5.account).amount).to equal_money(12.30)
        expect(t5.line_item_for(t5.account).posting_type).to eq('Debit')
        expect(t5.line_item_for(int_rcv_acct).amount).to equal_money(0.47)
        expect(t5.line_item_for(int_rcv_acct).reload.posting_type).to eq('Credit')
        expect(t5.line_item_for(prin_acct).amount).to equal_money(11.83)
        expect(t5.line_item_for(prin_acct).posting_type).to eq('Credit')

        # The interest change above cascades down into this txn.
        expect(t5.needs_qb_push).to be true

        # balances
        expect(t5.reload.principal_balance).to equal_money(140.67)
        expect(t5.reload.interest_balance).to equal_money(0.00)

        # t6 --------------------------------------------------------
        expect(t6.line_items.size).to eq(3)

        # account details
        expect(t6.line_item_for(t6.account).amount).to equal_money(23.7)
        expect(t6.line_item_for(t6.account).posting_type).to eq('Debit')
        expect(t6.line_item_for(int_rcv_acct).amount).to equal_money(11.85)
        expect(t6.line_item_for(int_rcv_acct).posting_type).to eq('Credit')
        expect(t6.line_item_for(prin_acct).amount).to equal_money(11.85)
        expect(t6.line_item_for(prin_acct).posting_type).to eq('Credit')

        # The interest change above cascades down into this txn.
        expect(t6.needs_qb_push).to be false

        # balances
        expect(t6.reload.principal_balance).to equal_money(128.82) # 140.67 - 11.85
        expect(t6.reload.interest_balance).to equal_money(-11.85)
      end
    end
  end

  describe 'creation of interest txns' do
    # There should be an interest txn between t0 and t1, but not before t0
    let!(:t0) { create(:accounting_transaction, :disbursement, amount: 10000.0,
      project: loan, txn_date: "2018-01-01", division: division) }
    let!(:t1) { create(:accounting_transaction, :disbursement, amount: 20000.0,
      project: loan, txn_date: "2018-01-04", division: division) }
    let(:all_txns) { [t0, t1] }

    it 'creates an interest txn before another txn' do
      recalculate_and_reload
      inttxn = Accounting::Transaction.interest_type.find_by(txn_date: '2018-01-04')
      expect(inttxn).not_to be_nil
      expect(inttxn.amount).to equal_money(6.58)
      expect(inttxn.description).to eq "Interest Accrual for Loan ##{loan.id}"
    end

    it 'creates an interest txn on the end of each month' do
      recalculate_and_reload
      inttxn = Accounting::Transaction.interest_type.find_by(txn_date: '2018-01-31')
      expect(inttxn).not_to be_nil
      # Principal balance should be 30000
      # Days since previous txn (1/4 to 1/31) = 27
      # .08/365 * 30000 * 27 = 177.53
      expect(inttxn.amount).to equal_money(177.53)
    end
  end

  def recalculate_and_reload
    reset_push_flags
    stubbed_calculator.recalculate
    all_txns.map(&:reload)
  end

  # We have to stub reconciler because it triggers calls to API.
  # We also have to stub associate_with_qb_obj because it depends on the result of reconciler.
  # We deliberately aren't memoizing this because we want a fresh calculator each time, as
  # that best simulates real behavior.
  def stubbed_calculator
    calculator = Accounting::InterestCalculator.new(loan)
    reconciler = double()
    allow(calculator).to receive(:reconciler).and_return(reconciler)
    allow(reconciler).to receive(:reconcile).and_return(nil)
    calculator.send(:transactions).each do |t|
      allow(t).to receive(:associate_with_qb_obj).with(nil).and_return(nil)
    end
    calculator
  end

  def reset_push_flags
    all_txns.each { |t| t.set_qb_push_flag!(false) }
  end
end
