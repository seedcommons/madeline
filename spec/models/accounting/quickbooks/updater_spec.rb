require 'rails_helper'

RSpec.describe Accounting::Quickbooks::Updater, type: :model do
  let(:connection) { instance_double(Accounting::Quickbooks::Connection, last_updated_at: last_updated_at) }
  let(:generic_service) { instance_double(Quickbooks::Service::ChangeDataCapture, since: double(all_types: [])) }

  subject { described_class.new(connection) }

  before do
    allow(subject).to receive(:service).and_return(generic_service)
    allow(connection).to receive(:update_attribute).with(:last_updated_at, anything)
  end

  describe '#update' do
    context 'when qb_connection is nil' do
      let(:last_updated_at) { nil }
      subject { described_class.new(nil) }

      it 'throws error' do
        expect { subject.update }.to raise_error(Accounting::Quickbooks::NotConnectedError)
      end
    end

    context 'when last_updated_at is nil' do
      let(:last_updated_at) { nil }

      it 'throws error' do
        expect { subject.update }.to raise_error(Accounting::Quickbooks::FullSyncRequiredError)
      end
    end

    context 'when last_updated_at is 31 days ago' do
      let(:last_updated_at) { 31.days.ago }

      it 'throws error' do
        expect { subject.update }.to raise_error(Accounting::Quickbooks::FullSyncRequiredError)
      end
    end

    context 'when last_updated_at is 30 days ago' do
      let(:last_updated_at) { 30.days.ago }

      it 'does not throw error' do
        expect { subject.update }.not_to raise_error
      end
    end

    context 'with new JournalEntry' do
      before do
        allow(subject).to receive(:changes).and_return('JournalEntry' => [journal_entry])
      end

      let(:last_updated_at) { 30.days.ago }
      let(:qb_id) { 34 }
      let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: qb_id) }

      subject { described_class.new(connection) }

      it 'creates a new transaction with the proper qb_id' do
        expect { subject.update }.to change { Accounting::Transaction.where(qb_id: qb_id).count }.by 1
      end

      it 'is created with proper type' do
        subject.update
        transaction = Accounting::Transaction.where(qb_id: qb_id).take

        expect(transaction.qb_transaction_type).to eq 'JournalEntry'
      end

      it 'is created with quickbooks data' do
        subject.update
        transaction = Accounting::Transaction.where(qb_id: qb_id).take

        expect(transaction.quickbooks_data).not_to be_empty
      end
    end

    context 'with updated JournalEntry' do
      before do
        allow(subject).to receive(:changes).and_return('JournalEntry' => [journal_entry])
        create(:journal_entry, qb_id: qb_id)
      end

      let(:last_updated_at) { 30.days.ago }
      let(:qb_id) { 34 }
      let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: qb_id) }

      subject { described_class.new(connection) }

      it 'does not create a new transaction' do
        expect { subject.update }.not_to change { Accounting::Transaction.where(qb_id: qb_id).count }
      end

      it 'is created with quickbooks data' do
        expect { subject.update }.to change { Accounting::Transaction.where(qb_id: qb_id).take.updated_at }
      end
    end

    context 'with deleted JournalEntry' do
      before do
        allow(subject).to receive(:changes).and_return('JournalEntry' => [journal_entry])
        create(:journal_entry, qb_id: qb_id)
      end

      let(:last_updated_at) { 30.days.ago }
      let(:qb_id) { 34 }
      let(:journal_entry) { instance_double(Quickbooks::Model::ChangeModel, id: qb_id, status: 'Deleted') }

      subject { described_class.new(connection) }

      it 'destroys transaction with the proper qb_id' do
        expect { subject.update }.to change { Accounting::Transaction.where(qb_id: qb_id).count }.by -1
      end
    end
  end
end
