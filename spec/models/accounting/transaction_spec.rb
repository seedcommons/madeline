require 'rails_helper'

# quickbooks_data['line_items'].each
RSpec.describe Accounting::Transaction, type: :model do
  let(:loan) { create(:loan, division: create(:division, :with_accounts)) }
  let(:transaction) { create(:accounting_transaction, project: loan) }

  describe '.standard_order' do
    let!(:txn_1) do
      create(:accounting_transaction,
        txn_date: Date.today,
        loan_transaction_type_value: 'repayment',
        created_at: Time.now - 1.minutes
      )
    end
    let!(:txn_2) do
      create(:accounting_transaction,
        txn_date: Date.today,
        loan_transaction_type_value: 'disbursement',
        created_at: Time.now - 2.minutes
      )
    end
    let!(:txn_3) do
      create(:accounting_transaction,
        txn_date: Date.today - 3,
        loan_transaction_type_value: 'disbursement',
        created_at: Time.now - 3.minutes
      )
    end
    let!(:txn_4) do
      create(:accounting_transaction,
        txn_date: Date.today - 3,
        loan_transaction_type_value: 'interest',
        created_at: Time.now - 10.minutes
      )
    end
    let!(:txn_5) do
      create(:accounting_transaction,
        txn_date: Date.today - 3,
        loan_transaction_type_value: 'interest',
        created_at: Time.now - 5.minutes
      )
    end

    before do
      OptionSetCreator.new.create_loan_transaction_type
    end

    it 'returns in the right order' do
      expect(Accounting::Transaction.standard_order).to eq([txn_4, txn_5, txn_3, txn_2, txn_1])
    end
  end

  describe 'qb_id' do
    let(:transaction_params) do
      {
        amount: nil,
        txn_date: '2017-10-31',
        private_note: 'a memo',
        description: 'desc',
        project_id: loan.id,
        qb_transaction_type: transaction_type
      }
    end

    context 'when disbursement transaction' do
      let(:transaction_type) { 'disbursement' }

      context 'without qb_id' do
        it 'requires an amount to save' do
          expect do
            create(:accounting_transaction, transaction_params.merge(qb_id: nil))
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'with qb_id' do
        it 'requires an amount to save' do
          expect do
            create(:accounting_transaction, transaction_params.merge(qb_id: 123))
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'when interest transaction' do
      let(:transaction_type) { 'interest' }

      context 'without qb_id' do
        it 'can save without amount' do
          expect do
            create(:accounting_transaction, transaction_params.merge(qb_id: nil))
          end.not_to raise_error
        end
      end

      context 'with qb_id' do
        it 'requires an amount to save' do
          expect do
            create(:accounting_transaction, transaction_params.merge(qb_id: 123))
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end

  context 'with line items' do
    let(:txn) { transaction }
    let(:int_inc_acct) { transaction.division.interest_income_account }
    let(:int_rcv_acct) { transaction.division.interest_receivable_account }
    let(:prin_acct) { transaction.division.principal_account }
    let!(:line_items) do
      create_line_item(txn, 'debit', 1.02, account: prin_acct)
      create_line_item(txn, 'debit', 2.07, account: int_rcv_acct)
      create_line_item(txn, 'debit', 1.5, account: int_inc_acct)
      create_line_item(txn, 'credit', 5, account: prin_acct)
      create_line_item(txn, 'credit', 3, account: int_rcv_acct)
      create_line_item(txn, 'credit', 1, account: int_inc_acct)

      # Decoys (factory will create accounts)
      create_line_item(txn, 'debit', 2.5)
      create_line_item(txn, 'credit', 11)
    end

    describe '#change_in_principal and #change_in_interest' do
      it 'calculates correctly' do
        expect(transaction.reload.change_in_principal).to eq(-3.98)
        expect(transaction.reload.change_in_interest).to eq(-0.93)
      end
    end

    describe '#calculate_balances' do
      it 'works without previous transaction' do
        transaction.calculate_balances
        expect(transaction.principal_balance).to eq(-3.98)
        expect(transaction.interest_balance).to eq(-0.93)
      end

      it 'works with previous transaction' do
        prev_tx = create(:accounting_transaction, principal_balance: 6.22, interest_balance: 4.50)

        transaction.calculate_balances(prev_tx: prev_tx)
        expect(transaction.principal_balance).to eq(2.24)
        expect(transaction.interest_balance).to eq(3.57)
      end
    end

    def create_line_item(txn, type, amount, options = {})
      create(:line_item, options.merge(parent_transaction: txn, posting_type: type, amount: amount))
    end
  end
end
