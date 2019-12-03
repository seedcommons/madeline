require 'rails_helper'

RSpec.describe Accounting::Quickbooks::TransactionFetcher, type: :model do
  let(:division) { create(:division, :with_accounts) }
  subject { described_class.new(division) }

  let(:generic_service) { instance_double(Quickbooks::Service::Account, all: []) }
  before do
    allow(subject).to receive(:service).and_return(generic_service)
  end

  it 'should work when a nil query result is returned' do
    service = instance_double(Quickbooks::Service::Deposit, all: nil)
    allow(subject).to receive(:service).with('Deposit').and_return(service)
    expect { subject.fetch }.to_not raise_error
  end

  it 'should fetch all records for JournalEntry' do
    service = instance_double(Quickbooks::Service::JournalEntry, all: [])
    allow(subject).to receive(:service).with('JournalEntry').and_return(service)
    expect(service).to receive(:all)
    subject.fetch
  end

  it 'should create Accounting::Transaction record' do
    service = instance_double(Quickbooks::Service::JournalEntry, all: [
      instance_double(Quickbooks::Model::JournalEntry, id: 99, as_json: self)
    ])
    allow(subject).to receive(:service).with('JournalEntry').and_return(service)

    expect { subject.fetch }.to change { Accounting::Transaction.all.count }.by(1)
    txn = Accounting::Transaction.first
    expect(txn.qb_object_type).to eq 'JournalEntry'
    expect(txn.qb_id).to eq '99'
  end
end
