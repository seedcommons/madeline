require 'rails_helper'

RSpec.describe Accounting::Quickbooks::TransactionCreator, type: :model do
  let(:class_ref) { instance_double(Quickbooks::Model::Class, id: 2) }
  let(:generic_service) { instance_double(Quickbooks::Service::JournalEntry, all: []) }
  let(:class_service) { instance_double(Quickbooks::Service::Class, find_by: [class_ref]) }
  let(:connection) { instance_double(Accounting::Quickbooks::Connection) }
  let(:account) { instance_double(Accounting::Account, qb_id: 98) }
  let(:creator) { described_class.new(instance_double(Division, qb_connection: connection, principal_account: account)) }

  before do
    allow(generic_service).to receive(:create)
    allow(creator).to receive(:service).and_return(generic_service)
    allow(creator).to receive(:class_service).and_return(class_service)
  end

  context 'when qb customer does exist' do
    let(:qb_customer_id) { 3 }
    let(:loan_id) { 2 }
    let(:amount) { 78.20 }
    let(:memo) { 'I am a memo' }
    let(:description) { 'I am a line item description' }

    subject do
      creator.add_disbursement(
        amount: amount,
        loan_id: loan_id,
        memo: memo,
        description: description,
        qb_bank_account_id: 89,
        qb_customer_id: qb_customer_id
      )
    end

    context 'generic_service' do
      it 'creates JournalEntry with 2 line items' do
        expect(generic_service).to receive(:create) do |arg|
          expect(arg.line_items.count).to eq 2
        end

        subject
      end

      it 'creates JournalEntry with 2 line items and customer refs' do
        expect(generic_service).to receive(:create) do |arg|
          arg.line_items.each do |item|
            expect(item.journal_entry_line_detail.entity.type).to eq 'Customer'
          end
        end

        subject
      end

      it 'creates JournalEntry with 2 line items and proper customer id' do
        expect(generic_service).to receive(:create) do |arg|
          arg.line_items.each do |item|
            expect(item.journal_entry_line_detail.entity.entity_ref.value).to eq qb_customer_id
          end
        end

        subject
      end

      it 'creates JournalEntry with 2 line items and proper amount' do
        expect(generic_service).to receive(:create) do |arg|
          arg.line_items.each do |item|
            expect(item.amount).to eq amount
          end
        end

        subject
      end

      it 'creates JournalEntry with 2 line items and proper description' do
        expect(generic_service).to receive(:create) do |arg|
          arg.line_items.each do |item|
            expect(item.description).to eq description
          end
        end

        subject
      end

      it 'creates JournalEntry with proper memo' do
        expect(generic_service).to receive(:create) do |arg|
          expect(arg.private_note).to eq memo
        end

        subject
      end
    end

    it 'creates JournalEntry with a reference to the existing loan' do
      expect(class_service).to receive(:find_by).with(:name, loan_id)

      subject
    end
  end
end
