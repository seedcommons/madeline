require 'rails_helper'

describe Accounting::InterestCalculator do
  let(:division) { create(:division, :with_accounts) }
  let(:loan) { create(:loan, division: division) }
  let(:t1) { create(:accounting_transaction, :with_interest, project: loan, txn_date: Date.today) }
  let(:t2) { create(:accounting_transaction, :with_disbursement, project: loan, txn_date: Date.today - 1.day) }
  let(:t3) { create(:accounting_transaction, :with_repayment, project: loan, txn_date: Date.today - 2.days) }
  let(:prin_acct) { division.principal_account }
  let(:int_rcv_acct) { division.interest_receivable_account }
  let(:int_inc_acct) { division.interest_income_account }

  context 'existing prior transaction' do

    describe 'after editing disbursement' do
      it 'updates the correct data' do
        t2.amount = 40
        t2.save!

        Accounting::InterestCalculator.new.recalculate_line_item(loan)
        loan.reload

        # size
        expect(t1.line_items.size).to eq(2)
        expect(t2.line_items.size).to eq(2)
        expect(t3.line_items.size).to eq(3)

        # account type
        expect(t1.line_items.map(&:accounting_account_id).uniq).to eq [int_rcv_acct, int_inc_acct]
        expect(t2.line_items.map(&:accounting_account_id).uniq).to eq [t2.account, prin_acct]
        expect(t3.line_items.map(&:accounting_account_id).uniq).to eq [t2.account, int_rcv_acct, prin_acct]

        # not too clear on how this trickles down to other txns yet

        # txn interest_balance and principal_balance
        # expect(t1.interest_balance).to eq(100)
        # expect(t1.principal_balance).to eq(0)

        # expect(t2.interest_balance).to eq(100)
        # expect(t2.principal_balance).to eq(0)

        # expect(t3.interest_balance).to eq(100)
        # expect(t3.principal_balance).to eq(0)

        # since there are two for credit and debit
        # expect(t1.line_items.first.amount).to eq(100)
        # expect(t1.line_items.last.amount).to eq(100)

        # since there are two for credit and debit
        # expect(t2.line_items.first.amount).to eq(40)
        # expect(t2.line_items.last.amount).to eq(40)

        # expect(t3.line_items.where(type: 'debit').first.amount).to eq(100)
        # expect(t3.line_items.where(type: 'credit').first.amount).to eq(40)
        # expect(t3.line_items.where(type: 'credit').last.amount).to eq(60)
      end
    end
  end

  context 'no existing prior transaction' do
    describe 'after editing disbursement' do
      it 'updates the correct data' do
        t1.amount = 25
        t1.save!

        Accounting::InterestCalculator.new.recalculate_line_item(loan)
        loan.reload

        # size
        expect(t1.line_items.size).to eq(2)
        expect(t2.line_items.size).to eq(2)
        expect(t3.line_items.size).to eq(3)

        # account type
        expect(t1.line_items.map(&:accounting_account_id).uniq).to eq [int_rcv_acct, int_inc_acct]
        expect(t2.line_items.map(&:accounting_account_id).uniq).to eq [t2.account, prin_acct]
        expect(t3.line_items.map(&:accounting_account_id).uniq).to eq [t2.account, int_rcv_acct, prin_acct]

        # not too clear on how this trickles down to other txns yet

        # txn interest_balance and principal_balance
        # expect(t1.interest_balance).to eq(25)
        # expect(t1.principal_balance).to eq(0)

        # expect(t2.interest_balance).to eq(25)
        # expect(t2.principal_balance).to eq(0)

        # expect(t3.interest_balance).to eq(25)
        # expect(t3.principal_balance).to eq(0)

        # since there are two for credit and debit
        # expect(t1.line_items.first.amount).to eq(25)
        # expect(t1.line_items.last.amount).to eq(25)

        # since there are two for credit and debit
        # expect(t2.line_items.first.amount).to eq(100)
        # expect(t2.line_items.last.amount).to eq(100)

        # expect(t3.line_items.where(type: 'debit').first.amount).to eq(100)
        # expect(t3.line_items.where(type: 'credit').first.amount).to eq(50)
        # expect(t3.line_items.where(type: 'credit').last.amount).to eq(50)
      end
    end
  end
end
