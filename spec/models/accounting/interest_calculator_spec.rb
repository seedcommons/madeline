require 'rails_helper'

describe Accounting::InterestCalculator do
  let(:division) { create(:division, :with_accounts) }
  let(:loan) { create(:loan, division: division) }
  let(:t1) { create(:accounting_transaction, :with_interest, project: loan) }
  let(:t2) { create(:accounting_transaction, :with_disbursement, project: loan) }

  context 'existing prior transaction' do
    let(:t3) { create(:accounting_transaction, :with_repayment, project: loan) }

    describe 'after editing disbursement' do
      it 'updates the correct data' do
        t2.amount = 50
        t2.save!

        Accounting::InterestCalculator.new.recalculate_line_item(loan)
        loan.reload

        expect(t1.line_items.first.amount).to eq(100)
        expect(t1.line_items.last.amount).to eq(100)
        expect(t2.line_items.first.amount).to eq(50)
        expect(t2.line_items.last.amount).to eq(50)
        expect(t3.line_items.first.amount).to eq(100)
        expect(t3.line_items.last.amount).to eq(100)
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

        expect(t1.line_items.first.amount).to eq(25)
        expect(t1.line_items.last.amount).to eq(25)
        expect(t2.line_items.first.amount).to eq(100)
        expect(t2.line_items.last.amount).to eq(100)
        expect(t3.line_items.first.amount).to eq(100)
        expect(t3.line_items.last.amount).to eq(100)
      end
    end
  end
end
