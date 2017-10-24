require 'rails_helper'

RSpec.describe Accounting::Quickbooks::TransactionReconciler, type: :model do
  let(:connection) { instance_double(Accounting::Quickbooks::Connection) }
  let(:created_journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: '115') }
  let(:builder) { instance_double(Accounting::Quickbooks::TransactionBuilder, build_for_qb: created_journal_entry) }
  let(:qb_principal_account_id) { '92' }
  let(:principal_account) { create(:accounting_account, qb_id: qb_principal_account_id) }
  let(:service) { instance_double(Quickbooks::Service::JournalEntry) }
  let(:qb_id) { '827' }
  let(:transaction) do
    create(:accounting_transaction, qb_id: qb_id)
  end

  subject do
    described_class.new(instance_double(Division, qb_connection: connection, principal_account: principal_account))
  end

  before do
    allow(subject).to receive(:service).and_return(service)
    allow(subject).to receive(:builder).and_return(builder)
  end

  context 'when transaction is nil' do
    it 'does not call service' do
      subject.reconcile(nil)
    end
  end

  context 'with no matching transaction in qbo' do
    let(:qb_id) { nil }

    it 'calls create with qbo transaction' do
      expect(service).to receive(:create).with(created_journal_entry)
      expect(builder).to receive(:build_for_qb).with(transaction)

      subject.reconcile(transaction)
    end
  end

  context 'with matching transaction in qbo' do
    it 'calls create with qbo transaction' do
      expect(service).to receive(:update).with(created_journal_entry)
      expect(builder).to receive(:build_for_qb).with(transaction)

      subject.reconcile(transaction)
    end
  end
end
