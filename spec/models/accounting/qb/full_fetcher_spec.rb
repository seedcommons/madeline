
require "rails_helper"

describe Accounting::QB::FullFetcher, type: :model do
  let!(:qb_connection) { create(:accounting_qb_connection) }
  let!(:principal_account) { create(:accounting_account, name: "Principal Account", qb_account_classification: "Asset") }
  let!(:interest_receivable_account) { create(:accounting_account, name: "Interest Rcvbl Account", qb_account_classification: "Asset") }
  let!(:interest_income_account) { create(:accounting_account, name: "Interest Income Account", qb_account_classification: "Revenue") }
  let!(:division) do
    division = Division.root
    division.update(
      principal_account: principal_account,
      interest_receivable_account: interest_receivable_account,
      interest_income_account: interest_income_account,
      qb_connection: qb_connection,
    )
    division
  end
  let!(:qb_department) { create(:department, division: division, name: "Test Dept") }
  let(:qb_account_service) do
    instance_double(Quickbooks::Service::Account, all: [
      instance_double(Quickbooks::Model::Account,
        id: principal_account.qb_id,
        name: principal_account.name,
        classification: principal_account.qb_account_classification),
      instance_double(Quickbooks::Model::Account,
        id: interest_receivable_account.qb_id,
        name: interest_receivable_account.name,
        classification: interest_receivable_account.qb_account_classification),
      instance_double(Quickbooks::Model::Account,
        id: interest_income_account.qb_id,
        name: interest_income_account.name,
        classification: interest_income_account.qb_account_classification)
    ])
  end
  let(:qb_transaction_service) { instance_double(Quickbooks::Service::JournalEntry, all: []) }
  let(:qb_customer_service) { instance_double(Quickbooks::Service::Customer, all: []) }
  let(:qb_department_service) {
    instance_double(Quickbooks::Service::Department, all: [
      instance_double(Quickbooks::Model::Department,
        id: qb_department.qb_id,
        name: qb_department.name)
    ])
  }
  let(:qb_vendor_service) { instance_double(Quickbooks::Service::Vendor, all: []) }
  let(:account_fetcher) { Accounting::QB::AccountFetcher.new(division) }
  let!(:account_fetcher_class) {
    class_double(Accounting::QB::AccountFetcher,
      new: account_fetcher).as_stubbed_const
  }
  let(:transaction_fetcher) { Accounting::QB::TransactionFetcher.new(division) }
  let!(:transaction_fetcher_class) {
    class_double(Accounting::QB::TransactionFetcher,
      new: transaction_fetcher).as_stubbed_const
  }
  let(:transaction_class_finder_stub) { double("find_by_name": nil) }
  let(:customer_fetcher) { Accounting::QB::CustomerFetcher.new(division) }
  let!(:customer_fetcher_class) {
    class_double(Accounting::QB::CustomerFetcher,
      new: customer_fetcher).as_stubbed_const
  }
  let(:department_fetcher) { Accounting::QB::DepartmentFetcher.new(division) }
  let!(:department_fetcher_class) {
    class_double(Accounting::QB::DepartmentFetcher,
      new: department_fetcher).as_stubbed_const
  }
  let(:vendor_fetcher) { Accounting::QB::VendorFetcher.new(division) }
  let!(:vendor_fetcher_class) {
    class_double(Accounting::QB::VendorFetcher,
      new: vendor_fetcher).as_stubbed_const
  }

  subject { described_class.new(division) }

  describe "#fetch_all" do
    it "removes and restores accounts, restores division-dept associations" do
      stored_account_ids = division.accounts.map(&:id)
      expect(division.qb_department.name).to eq "Test Dept"

      expect(division.accounts.count).to eq 3

      expect(::Accounting::QB::TransactionClassFinder).to receive(:new).and_return(transaction_class_finder_stub)
      expect(account_fetcher).to receive(:service).with("Account").and_return(qb_account_service)
      expect(account_fetcher).to receive(:fetch).and_call_original
      expect(customer_fetcher).to receive(:service).with("Customer").and_return(qb_customer_service)
      expect(customer_fetcher).to receive(:fetch).and_call_original
      expect(department_fetcher).to receive(:service).with("Department").and_return(qb_department_service)
      expect(department_fetcher).to receive(:fetch).and_call_original
      expect(vendor_fetcher).to receive(:service).with("Vendor").and_return(qb_vendor_service)
      expect(vendor_fetcher).to receive(:fetch).and_call_original

      transaction_type_count = Accounting::Transaction::QB_OBJECT_TYPES.count
      expect(transaction_fetcher).to receive(:service).exactly(transaction_type_count).times
        .and_return(qb_transaction_service)
      expect(transaction_fetcher).to receive(:fetch).and_call_original

      expect(qb_connection).to receive :update_attribute

      subject.fetch_all
      division = Division.root

      new_account_ids = division.accounts.map(&:id)

      # Accounts should be restored with the same QB ids but they should have different DB ids
      expect(division.reload.accounts.count).to eq 3
      expect(stored_account_ids).not_to match_array new_account_ids
      expect(division.reload.qb_department.name).to eq qb_department.name
    end

    context "qb fetch errors" do
      it "deletes qb connection, clears qb data, and reraises error" do
        allow(::Accounting::QB::TransactionClassFinder).to receive(:new).and_raise(StandardError, "some qb error")
        expect(subject).to receive(:delete_qb_data).twice
        expect(subject).to receive(:clear_division_accounts).twice
        expect(qb_connection.present?).to be true
        expect { subject.fetch_all }.to raise_error("some qb error")
        expect(division.reload.qb_connection).to be_nil
      end
    end

    context "with missing division account" do
      let(:qb_account_service) do
        instance_double(Quickbooks::Service::Account, all: [
          instance_double(Quickbooks::Model::Account,
            id: principal_account.qb_id,
            name: principal_account.name,
            classification: principal_account.qb_account_classification),
          instance_double(Quickbooks::Model::Account,
            id: interest_income_account.qb_id,
            name: interest_income_account.name,
            classification: interest_income_account.qb_account_classification)
        ])
      end

      it "sets division account association to nil if account no longer exists after fetch" do
        division = Division.root

        expect(division.interest_receivable_account).not_to be_nil
        expect(::Accounting::QB::TransactionClassFinder).to receive(:new).and_return(transaction_class_finder_stub)
        expect(account_fetcher).to receive(:service).with("Account").and_return(qb_account_service)
        expect(account_fetcher).to receive(:fetch).and_call_original
        expect(customer_fetcher).to receive(:service).with("Customer").and_return(qb_customer_service)
        expect(customer_fetcher).to receive(:fetch).and_call_original
        expect(department_fetcher).to receive(:service).with("Department").and_return(qb_department_service)
        expect(department_fetcher).to receive(:fetch).and_call_original
        expect(vendor_fetcher).to receive(:service).with("Vendor").and_return(qb_vendor_service)
        expect(vendor_fetcher).to receive(:fetch).and_call_original

        transaction_type_count = Accounting::Transaction::QB_OBJECT_TYPES.count
        expect(transaction_fetcher).to receive(:service).exactly(transaction_type_count).times
          .and_return(qb_transaction_service)
        expect(transaction_fetcher).to receive(:fetch).and_call_original

        expect(qb_connection).to receive :update_attribute

        subject.fetch_all
        division = Division.root

        expect(division.interest_receivable_account).to be_nil
      end
    end
  end
end
