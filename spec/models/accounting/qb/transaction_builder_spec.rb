require "rails_helper"

RSpec.describe Accounting::QB::TransactionBuilder, type: :model do
  let(:connection) { instance_double(Accounting::QB::Connection) }
  let(:class_ref) { instance_double(Quickbooks::Model::Class, id: loan_id) }
  let(:class_service) { instance_double(Quickbooks::Service::Class, find_by: [class_ref]) }
  let(:customer) { create(:accounting_customer) }
  let(:customer_service) { instance_double(Quickbooks::Service::Customer) }
  let(:qb_bank_account_id) { "89" }
  let(:qb_principal_account_id) { "92" }
  let(:qb_office_account_id) { "1" }
  let(:principal_account) { create(:accounting_account, qb_id: qb_principal_account_id) }
  let(:bank_account) { create(:accounting_account, qb_id: qb_bank_account_id) }
  let(:office_account) { create(:accounting_account, qb_id: qb_office_account_id) }
  let(:loan) { create(:loan) }
  let(:loan_id) { loan.id }
  let(:amount) { 78.20 }
  let(:memo) { "I am a memo" }
  let(:description) { "I am a line item description" }
  let(:date) { Time.zone.today }

  subject do
    described_class.new(instance_double(Division,
                                        qb_connection: connection, principal_account: principal_account))
  end

  before do
    allow(subject).to receive(:class_service).and_return(class_service)
    allow(subject).to receive(:department_reference).and_return(department_reference)
  end

  let(:qb_customer_id) { "91234" }
  let(:qb_department_id) { "4012" }
  let(:department_reference) { instance_double(Quickbooks::Model::BaseReference, value: qb_department_id) }
  let(:customer_name) { "A cooperative with a name" }
  let(:organization) { create(:organization, name: customer_name, qb_id: nil) }

  describe "a purchase" do
    before do
      transaction.line_items << [prin_line_item, line_item_2]
    end
    let(:disbursement_type) { :check }
    let(:check_number) { "123" }
    let(:transaction) do
      Accounting::Transaction.create(
        amount: amount,
        customer: customer,
        project: loan,
        private_note: memo,
        description: description,
        account: bank_account,
        loan_transaction_type_value: :disbursement,
        txn_date: date,
        disbursement_type: disbursement_type,
        check_number: check_number
      )
    end

    let(:prin_line_item) {
      build(:line_item,
            account: principal_account,
            posting_type: "Debit",
            amount: 100)
    }

    let(:line_item_2) {
      build(:line_item,
            account: bank_account,
            posting_type: "Credit",
            amount: 25)
    }

    context "non-check disb" do
      let(:disbursement_type) { :other }
      it "sets payment_type to cash" do
        p = subject.build_for_qb transaction
        expect(p.payment_type).to eq "Cash"
      end
    end

    it "calls create with correct data" do
      expect(transaction.qb_object_type).to eq "Purchase"
      p = subject.build_for_qb transaction

      # disbursements exist in qb as purchases that have 1 li
      # disbursements have 2 lis in madeline
      # see purchase_extractor that adds the 2nd line item when a txn
      # is imported to madeline from qb
      expect(p.line_items.count).to eq 1
      expect(p.private_note).to eq memo
      expect(p.doc_number).to include "MS-Managed"
      expect(p.doc_number).to include check_number
      expect(p.txn_date).to eq date
      li = p.line_items.first
      expect(li.detail_type).to eq "AccountBasedExpenseLineDetail"
      expect(li.id).to eq prin_line_item.qb_line_id
      expect(li.amount).to eq transaction.amount
      expect(li.description).to eq description
      detail = li.account_based_expense_line_detail
      expect(detail.account_ref.name).to eq principal_account.name
      expect(detail.customer_ref.name).to eq customer.name
      expect(detail.billable_status).to eq "NotBillable"
    end
  end

  describe "a journal entry" do
    before do
      transaction.line_items << [line_item_1, line_item_2, line_item_3]
    end
    let(:transaction) do
      Accounting::Transaction.create(
        amount: amount,
        customer: customer,
        project: loan,
        private_note: memo,
        description: description,
        account: bank_account,
        loan_transaction_type_value: :repayment,
        txn_date: date
      )
    end

    let(:line_item_1) {
      build(:line_item,
            account: office_account,
            posting_type: "Debit",
            amount: 100)
    }

    let(:line_item_2) {
      build(:line_item,
            account: bank_account,
            posting_type: "Credit",
            amount: 25)
    }

    let(:line_item_3) {
      build(:line_item,
            account: principal_account,
            posting_type: "Credit",
            amount: 75)
    }

    it "calls create with correct data" do
      expect(transaction.qb_object_type).to eq "JournalEntry"
      je = subject.build_for_qb transaction

      expect(je.line_items.count).to eq 3
      expect(je.private_note).to eq memo
      expect(je.doc_number).to eq "MS-Managed"
      expect(je.txn_date).to eq date

      list = je.line_items
      expect(list.map(&:amount)).to eq transaction.line_items.map(&:amount)
      expect(list.map(&:description).uniq).to eq ["I am a line item description"]

      details = list.map { |i| i.journal_entry_line_detail }
      expect(details.map { |i| i.posting_type }.uniq).to match_array %w(Debit Credit)
      expect(details.map { |i| i.entity.entity_ref.value }.uniq).to eq [customer.qb_id]
      expect(details.map { |i| i.class_ref.value }.uniq).to eq [loan_id]
      # parent_ref on a qb class is not queryable in qb api, so not tested here; must use qb
      # to verify that parent class set correctly
      expect(details.map { |i| i.department_ref.value }.uniq).to eq [qb_department_id]
      expect(details.map { |i| i.account_ref.value }.uniq).to match_array [qb_bank_account_id, qb_principal_account_id, qb_office_account_id]
    end
  end
end
