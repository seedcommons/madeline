require 'rails_helper'

RSpec.describe Accounting::Quickbooks::TransactionReconciler, type: :model do
  let(:connection) { instance_double(Accounting::Quickbooks::Connection) }
  let(:created_journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: '115') }
  let(:builder) { instance_double(Accounting::Quickbooks::TransactionBuilder, build_for_qb: created_journal_entry) }
  let(:qb_principal_account_id) { '92' }
  let(:principal_account) { create(:accounting_account, qb_id: qb_principal_account_id) }
  let(:service) { instance_double(Quickbooks::Service::JournalEntry, create: created_journal_entry, update: created_journal_entry) }
  let(:qb_id) { '827' }
  let(:transaction) { create(:accounting_transaction, qb_id: qb_id) }

  subject do
    described_class.new(instance_double(Division, qb_connection: connection, principal_account: principal_account))
  end

  before do
    allow(subject).to receive(:service).and_return(service)
    allow(subject).to receive(:builder).and_return(builder)
  end

  context 'with needs_qb_push set to false' do
    before { transaction.set_qb_push_flag!(false) }

    it 'does nothing' do
      expect(service).not_to receive(:update)
      expect(service).not_to receive(:create)
      subject.reconcile(transaction)
    end
  end

  context 'with needs_qb_push set to true' do
    shared_examples_for 'sets needs_qb_push to false' do
      it do
        expect(transaction.needs_qb_push).to be true
        subject.reconcile(transaction)
        expect(transaction.needs_qb_push).to be false
      end
    end

    context 'with no matching transaction in qbo' do
      let(:qb_id) { nil }

      it_behaves_like 'sets needs_qb_push to false'

      it 'calls create with qbo transaction' do
        expect(builder).to receive(:build_for_qb).with(transaction)
        expect(service).to receive(:create).with(created_journal_entry)
        subject.reconcile(transaction)
      end
    end

    context 'with matching transaction in qbo' do
      it_behaves_like 'sets needs_qb_push to false'

      it 'calls update with qbo transaction' do
        expect(builder).to receive(:build_for_qb).with(transaction)
        expect(service).to receive(:update).with(created_journal_entry, sparse: true)
        subject.reconcile(transaction)
      end
    end
  end
end
