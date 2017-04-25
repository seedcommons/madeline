require 'rails_helper'

RSpec.describe Accounting::Quickbooks::Updater, type: :model do
  let(:connection) { instance_double(Accounting::Quickbooks::Connection, last_updated_at: last_updated_at) }
  subject { described_class.new(connection) }

  let(:generic_service) { instance_double(Quickbooks::Service::ChangeDataCapture, since: double(all_types: [])) }
  before do
    allow(subject).to receive(:service).and_return(generic_service)
    allow(connection).to receive(:last_updated_at=)
  end

  describe '#update' do
    context 'with updates_since is nil' do
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
    end

    context 'with updates_since is 31 days ago' do
      context 'when last_updated_at is nil' do
        let(:last_updated_at) { nil }

        it 'throws error' do
          expect { subject.update(updates_since: 31.days.ago) }.to raise_error(Accounting::Quickbooks::FullSyncRequiredError)
        end
      end
      context 'when last_updated_at is 31 days ago' do
        let(:last_updated_at) { 31.days.ago }

        it 'throws error' do
          expect { subject.update(updates_since: 31.days.ago) }.to raise_error(Accounting::Quickbooks::FullSyncRequiredError)
        end
      end
      context 'when last_updated_at is 30 days ago' do
        let(:last_updated_at) { 30.days.ago }

        it 'throws error' do
          expect { subject.update(updates_since: 31.days.ago) }.to raise_error(Accounting::Quickbooks::FullSyncRequiredError)
        end
      end
    end

    context 'with updates_since is 30 days ago' do
      context 'when last_updated_at is nil' do
        let(:last_updated_at) { nil }

        it 'does not throw error' do
          expect { subject.update(updates_since: 30.days.ago) }.not_to raise_error
        end
      end
      context 'when last_updated_at is 31 days ago' do
        let(:last_updated_at) { 31.days.ago }

        it 'does not throw error' do
          expect { subject.update(updates_since: 30.days.ago) }.not_to raise_error
        end
      end
      context 'when last_updated_at is 30 days ago' do
        let(:last_updated_at) { 30.days.ago }

        it 'does not throw error' do
          expect { subject.update(updates_since: 30.days.ago) }.not_to raise_error
        end
      end
    end
  end
end
