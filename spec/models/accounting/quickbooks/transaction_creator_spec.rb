require 'rails_helper'

RSpec.describe Accounting::Quickbooks::TransactionCreator, type: :model do
  let(:class_ref) { instance_double(Quickbooks::Model::Class, id: 2) }
  let(:generic_service) { instance_double(Quickbooks::Service::JournalEntry, all: []) }
  let(:class_service) { instance_double(Quickbooks::Service::Class, find_by: [class_ref]) }
  let(:connection) { instance_double(Accounting::Quickbooks::Connection) }
  let(:account) { instance_double(Accounting::Account, qb_id: 98) }
  subject { described_class.new(instance_double(Division, qb_connection: connection, interest_receivable_account: account)) }

  before do
    allow(subject).to receive(:service).and_return(generic_service)
    allow(subject).to receive(:class_service).and_return(class_service)
  end

  it 'should create class ref, and create journal entry' do
    expect(generic_service).to receive(:create)
    expect(class_service).to receive(:find_by)

    subject.add_disbursement(
      amount: 12.09,
      loan_id: 2,
      memo: 'I am memo',
      qb_bank_account_id: 89,
      qb_customer_id: 3
    )
  end
end
