require 'rails_helper'

RSpec.describe Accounting::Quickbooks::TransactionCreator, type: :model do
  let(:class_ref) { instance_double(Quickbooks::Model::Class, id: loan_id) }
  let(:generic_service) { instance_double(Quickbooks::Service::JournalEntry, all: [], create: nil) }
  let(:class_service) { instance_double(Quickbooks::Service::Class, find_by: [class_ref]) }
  let(:customer_service) { instance_double(Quickbooks::Service::Customer) }
  let(:department_service) { instance_double(Quickbooks::Service::Department) }
  let(:connection) { instance_double(Accounting::Quickbooks::Connection) }
  let(:principal_account) { create(:accounting_account, qb_id: qb_principal_account_id) }
  let(:bank_account) { create(:accounting_account, qb_id: qb_bank_account_id) }
  let(:loan) { create(:loan) }
  let(:loan_id) { loan.id }
  let(:amount) { 78.20 }
  let(:memo) { 'I am a memo' }
  let(:description) { 'I am a line item description' }
  let(:qb_bank_account_id) { '89' }
  let(:qb_principal_account_id) { '92' }
  let(:date) { nil }
  let(:transaction) do
    Accounting::Transaction.new(
      amount: amount,
      project: loan,
      private_note: memo,
      description: description,
      account: bank_account,
      txn_date: date
    )
  end

  let(:creator) { described_class.new(instance_double(Division, qb_connection: connection, principal_account: principal_account)) }

  subject do
    creator.add_disbursement transaction
  end

  before do
    allow(creator).to receive(:service).and_return(generic_service)
    allow(creator).to receive(:class_service).and_return(class_service)
    allow(creator).to receive(:customer_reference).and_return(customer_reference)
    allow(creator).to receive(:department_reference).and_return(department_reference)
  end

  let(:qb_customer_id) { '91234' }
  let(:qb_department_id) { '4012' }
  let(:customer_reference) { instance_double(Quickbooks::Model::Entity) }
  let(:department_reference) { instance_double(Quickbooks::Model::BaseReference, value: qb_department_id) }
  let(:customer_name) { 'A cooperative with a name' }
  let(:organization) { create(:organization, name: customer_name, qb_id: nil) }

  it 'calls create with correct data' do
    expect(generic_service).to receive(:create) do |arg|
      expect(arg.line_items.count).to eq 2
      expect(arg.private_note).to eq memo
      expect(arg.txn_date).to be_nil

      list = arg.line_items
      expect(list.map(&:amount).uniq).to eq [amount]
      expect(list.map(&:description).uniq).to eq [description]

      details = list.map { |i| i.journal_entry_line_detail }
      expect(details.map { |i| i.posting_type }.uniq).to match_array %w(Debit Credit)
      expect(details.map { |i| i.entity }.uniq).to eq [customer_reference]
      expect(details.map { |i| i.class_ref.value }.uniq).to eq [loan_id]
      expect(details.map { |i| i.department_ref.value }.uniq).to eq [qb_department_id]
      expect(details.map { |i| i.account_ref.value }.uniq).to match_array [qb_bank_account_id, qb_principal_account_id]
    end
    subject
  end

  context 'and date is supplied' do
    let(:date) { 3.days.ago.to_date }

    it 'creates JournalEntry with date' do
      expect(generic_service).to receive(:create) do |arg|
        expect(arg.txn_date).to eq date
      end
      subject
    end
  end

  it 'creates JournalEntry with a reference to the existing loan' do
    expect(class_service).to receive(:find_by).with(:name, loan_id)
    subject
  end


  context 'and date is supplied' do
    let(:date) { 3.days.ago.to_date }

    it 'creates JournalEntry with date' do
      expect(generic_service).to receive(:create) do |arg|
        expect(arg.txn_date).to eq date
      end
      subject
    end
  end
end
