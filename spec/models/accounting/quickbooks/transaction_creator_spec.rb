require 'rails_helper'

RSpec.describe Accounting::Quickbooks::TransactionCreator, type: :model do
  let(:class_ref) { instance_double(Quickbooks::Model::Class, id: 2) }
  let(:generic_service) { instance_double(Quickbooks::Service::JournalEntry, all: [], create: nil) }
  let(:class_service) { instance_double(Quickbooks::Service::Class, find_by: [class_ref]) }
  let(:customer_service) { instance_double(Quickbooks::Service::Customer) }
  let(:connection) { instance_double(Accounting::Quickbooks::Connection) }
  let(:account) { instance_double(Accounting::Account, qb_id: qb_principal_account_id) }
  let(:qb_customer_id) { "3" }
  let(:loan_id) { 2 }
  let(:amount) { 78.20 }
  let(:memo) { 'I am a memo' }
  let(:description) { 'I am a line item description' }
  let(:qb_bank_account_id) { 89 }
  let(:qb_principal_account_id) { 92 }
  let(:date) { nil }

  let(:creator) { described_class.new(instance_double(Division, qb_connection: connection, principal_account: account)) }

  subject do
    creator.add_disbursement(
      amount: amount,
      loan_id: loan_id,
      memo: memo,
      description: description,
      qb_bank_account_id: qb_bank_account_id,
      organization: organization,
      date: date
    )
  end

  before do
    allow(creator).to receive(:service).and_return(generic_service)
    allow(creator).to receive(:class_service).and_return(class_service)
    allow(creator).to receive(:customer_service).and_return(customer_service)
  end

  context 'when qb customer does not exist' do
    let(:qb_new_customer_id) { "91234" }
    let(:qb_new_customer) { instance_double(Quickbooks::Model::Customer, id: qb_new_customer_id) }
    let(:customer_service) { instance_double(Quickbooks::Service::Customer, create: qb_new_customer) }
    let(:customer_name) { 'A cooperative with a name' }
    let(:organization) { create(:organization, name: customer_name, qb_id: nil ) }

    context 'generic_service' do
      it 'creates JournalEntry with correct data' do
        expect(generic_service).to receive(:create) do |arg|
          expect(arg.line_items.count).to eq 2
          expect(arg.private_note).to eq memo
          expect(arg.txn_date).to be_nil

          list = arg.line_items
          expect(list.map(&:amount).uniq).to eq [amount]
          expect(list.map(&:description).uniq).to eq [description]

          details = list.map { |i| i.journal_entry_line_detail }
          expect(details.map { |i| i.posting_type }.uniq).to match_array %w(Debit Credit)
          expect(details.map { |i| i.entity.type }.uniq).to eq %w(Customer)
          expect(details.map { |i| i.entity.entity_ref.value }.uniq).to eq [qb_new_customer_id]
          expect(details.map { |i| i.class_ref.value }.uniq).to eq [loan_id]
          expect(details.map { |i| i.account_ref.value }.uniq).to match_array [qb_bank_account_id, qb_principal_account_id]
        end
        subject
      end

      it 'creates Customer with correct data' do
        expect(customer_service).to receive(:create) do |arg|
          expect(arg.display_name).to eq customer_name
        end.and_return(qb_new_customer)
        subject
      end

      context 'and date is supplied' do
        let(:date) { 3.days.ago }

        it 'creates JournalEntry with date' do
          expect(generic_service).to receive(:create) do |arg|
            expect(arg.txn_date).to eq date
          end
          subject
        end
      end
    end
  end

  context 'when qb customer does exist' do
    let(:organization) { create(:organization, qb_id: qb_customer_id) }

    context 'generic_service' do
      it 'creates JournalEntry with correct data' do
        expect(generic_service).to receive(:create) do |arg|
          expect(arg.line_items.count).to eq 2
          expect(arg.private_note).to eq memo
          expect(arg.txn_date).to be_nil

          list = arg.line_items
          expect(list.map(&:amount).uniq).to eq [amount]
          expect(list.map(&:description).uniq).to eq [description]

          details = list.map { |i| i.journal_entry_line_detail }
          expect(details.map { |i| i.posting_type }.uniq).to match_array %w(Debit Credit)
          expect(details.map { |i| i.entity.type }.uniq).to eq %w(Customer)
          expect(details.map { |i| i.entity.entity_ref.value }.uniq).to eq [qb_customer_id]
          expect(details.map { |i| i.class_ref.value }.uniq).to eq [loan_id]
          expect(details.map { |i| i.account_ref.value }.uniq).to match_array [qb_bank_account_id, qb_principal_account_id]
        end
        subject
      end

      context 'and date is supplied' do
        let(:date) { 3.days.ago }

        it 'creates JournalEntry with date' do
          expect(generic_service).to receive(:create) do |arg|
            expect(arg.txn_date).to eq date
          end
          subject
        end
      end
    end

    it 'creates JournalEntry with a reference to the existing loan' do
      expect(class_service).to receive(:find_by).with(:name, loan_id)
      subject
    end
  end
end
