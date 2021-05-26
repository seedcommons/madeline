require "rails_helper"

# TODO: find a way to stub less of this workflow/add more unit tests.
# The specs are not catching when the update method receives a loan or an array of loans

RSpec.describe Accounting::QB::Updater, type: :model do
  let(:generic_service) { instance_double(Quickbooks::Service::ChangeDataCapture, since: double(all_types: [])) }
  let(:qb_id) { 1982547353 }
  let!(:qb_connection) { create(:accounting_qb_connection) }
  let!(:prin_acct) { create(:accounting_account, name: "Principal Account", qb_account_classification: "Asset") }
  let!(:int_rcv_acct) { create(:accounting_account, name: "Interest Rcvbl Account", qb_account_classification: "Asset") }
  let!(:int_inc_acct) { create(:accounting_account, name: "Interest Income Account", qb_account_classification: "Revenue") }
  let!(:division) do
    division = Division.root
    division.update(
      principal_account: prin_acct,
      interest_receivable_account: int_rcv_acct,
      interest_income_account: int_inc_acct,
      qb_connection: qb_connection,
    )
    division
  end
  let(:txn_acct) { create(:account, name: "Some Bank Account") }
  let(:loan) { create(:loan, division: division) }
  let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: qb_id, as_json: quickbooks_data) }

  # This is example JSON that might be returned by the QB API.
  # The data are taken from the docs/example_calculation.xlsx file, row 7.
  let(:quickbooks_data) do
    {"line_items" =>
     [{"id" => "0",
       "description" => "Repayment",
       "amount" => "10.99",
       "detail_type" => "JournalEntryLineDetail",
       "journal_entry_line_detail" => {
         "posting_type" => "Credit",
         "entity" => {
           "type" => "Customer",
           "entity_ref" => {"value" => "1", "name" => "Amy's Bird Sanctuary", "type" => nil}
         },
         "account_ref" => {"value" => prin_acct.qb_id, "name" => prin_acct.name, "type" => nil},
         "class_ref" => {"value" => "5000000000000026437", "name" => "Loan Products:Loan ID #{loan.id}", "type" => nil},
         "department_ref" => nil
       }},
      {"id" => "1",
       "description" => "Repayment",
       "amount" => "1.31",
       "detail_type" => "JournalEntryLineDetail",
       "journal_entry_line_detail" => {
         "posting_type" => "Credit",
         "entity" => {
           "type" => "Customer",
           "entity_ref" => {"value" => "1", "name" => "Amy's Bird Sanctuary", "type" => nil}
         },
         "account_ref" => {"value" => int_rcv_acct.qb_id, "name" => int_rcv_acct.name, "type" => nil},
         "class_ref" => {"value" => "5000000000000026437", "name" => "Loan Products:Loan ID #{loan.id}", "type" => nil},
         "department_ref" => nil
       }},
      {"id" => "2",
       "description" => "Repayment",
       "amount" => "12.30",
       "detail_type" => "JournalEntryLineDetail",
       "journal_entry_line_detail" => {
         "posting_type" => "Debit",
         "entity" => {
           "type" => "Customer",
           "entity_ref" => {"value" => "1", "name" => "Amy's Bird Sanctuary", "type" => nil}
         },
         "account_ref" => {"value" => txn_acct.qb_id, "name" => txn_acct.name, "type" => nil},
         "class_ref" => {"value" => "5000000000000026437", "name" => "Loan Products:Loan ID #{loan.id}", "type" => nil},
         "department_ref" => nil
       }}],
     "id" => "167",
     "sync_token" => 0,
     "meta_data" => {
       "create_time" => "2017-04-18T10:14:30.000-07:00",
       "last_updated_time" => "2017-04-18T10:14:30.000-07:00"
     },
     "txn_date" => "2017-04-18",
     "total" => "12.30",
     "doc_number" => "textme",
     "private_note" => "Random stuff"}
  end

  let(:txn) { create(:accounting_transaction, project: loan, quickbooks_data: quickbooks_data) }

  # These line items match the JSON above.
  let!(:line_items) do
    txn.line_items = [create(:line_item,
                             qb_line_id: 0,
                             amount: "10.99",
                             account: prin_acct,
                             posting_type: "Credit"),
                      create(:line_item,
                             qb_line_id: 1,
                             amount: "1.31",
                             account: int_rcv_acct,
                             posting_type: "Credit"),
                      create(:line_item,
                             qb_line_id: 2,
                             amount: "12.30",
                             account: txn_acct,
                             posting_type: "Debit")]
  end

  subject { described_class.new(division.qb_connection) }

  before do
    allow(subject).to receive(:service).and_return(generic_service)
    allow(division).to receive(:qb_division).and_return(division)
  end

  describe "#update" do
    let(:last_updated_at) { 100.years.ago }

    before do
      division.qb_connection.update_attribute(:last_updated_at, last_updated_at)
    end

    context "when last_updated_at is very old" do
      it "throws error" do
        expect { subject.update }.to raise_error(Accounting::QB::DataResetRequiredError)
      end

      context "when qb_connection is nil" do
        subject { described_class.new(nil) }

        it "throws error" do
          expect { subject.update }.to raise_error(Accounting::QB::NotConnectedError)
        end
      end
    end

    context "when last_updated_at is 31 days ago" do
      let(:last_updated_at) { 370.days.ago }

      it "throws error" do
        expect { subject.update }.to raise_error(Accounting::QB::DataResetRequiredError)
      end
    end

    context "when last_updated_at is less than 5 seconds ago" do
      let(:last_updated_at) { 4.seconds.ago }

      it "returns without doing anything" do
        expect(subject).not_to receive(:changes)
        subject.update
      end
    end

    context "when last_updated_at is 30 days ago" do
      let(:last_updated_at) { 30.days.ago }

      before do
        allow(subject).to receive(:changes).and_return("JournalEntry" => [journal_entry])
      end

      it "does not throw error" do
        expect { subject.update }.not_to raise_error
      end

      context "when transaction does not yet exist locally" do
        it "creates a new transaction with the correct data" do
          subject.update

          transaction = Accounting::Transaction.where(qb_id: qb_id).take
          expect(transaction).not_to be_nil
          expect(transaction.qb_object_type).to eq "JournalEntry"
          expect(transaction.quickbooks_data).not_to be_empty
        end
      end

      context "when transaction synced, but was updated in QBO" do
        let!(:journal_entry_transaction) { create(:journal_entry_transaction, qb_id: qb_id, quickbooks_data: quickbooks_data) }
        let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: qb_id, as_json: updated_quickbooks_data) }
        let(:new_loan) { create(:loan) }
        let(:updated_quickbooks_data) do
          {"line_items" =>
           [{"id" => "0",
             "description" => "New desc",
             "amount" => "0.24",
             "detail_type" => "JournalEntryLineDetail",
             "journal_entry_line_detail" => {
               "posting_type" => "Debit",
               "entity" => {
                 "type" => "Customer",
                 "entity_ref" => {"value" => "1", "name" => "Amy's Bird Sanctuary", "type" => nil}
               },
               "account_ref" => {"value" => "84", "name" => "Accounts Receivable (A/R)", "type" => nil},
               "class_ref" => {"value" => "5000000000000026437", "name" => "Loan Products:Loan ID #{new_loan.id}", "type" => nil},
               "department_ref" => nil
             }},
            {"id" => "1",
             "description" => "Nate desc",
             "amount" => "0.24",
             "detail_type" => "JournalEntryLineDetail",
             "journal_entry_line_detail" => {
               "posting_type" => "Credit",
               "entity" => {
                 "type" => "Customer",
                 "entity_ref" => {"value" => "1", "name" => "Amy's Bird Sanctuary", "type" => nil}
               },
               "account_ref" => {"value" => "35", "name" => "Checking", "type" => nil},
               "class_ref" => {"value" => "5000000000000026437", "name" => "Loan Products:Loan ID #{new_loan.id}", "type" => nil},
               "department_ref" => nil
             }}],
           "id" => "167",
           "sync_token" => 0,
           "meta_data" => {
             "create_time" => "2017-04-18T10:14:30.000-07:00",
             "last_updated_time" => "2017-04-18T10:14:30.000-07:00"
           },
           "txn_date" => "2017-07-08",
           "total" => "407.22",
           "doc_number" => "MS-textme",
           "private_note" => "New note"}
        end

        it "does not create a new transaction" do
          expect { subject.update }.not_to change { Accounting::Transaction.where(qb_id: qb_id).count }
        end

        it "updates transaction timestamp" do
          expect { subject.update }.to change { Accounting::Transaction.find_by(qb_id: qb_id).updated_at }
        end

        it "updates transaction fields" do
          subject.update

          t = Accounting::Transaction.find_by(qb_id: qb_id)
          expect(t.quickbooks_data).to eq(updated_quickbooks_data)
        end
      end

      context "when Transaction created locally, but not synced to QBO" do
        let!(:journal_entry_transaction) { create(:journal_entry_transaction, qb_id: qb_id) }

        context "with updated JournalEntry" do
          it "does not create a new transaction" do
            expect { subject.update }.not_to change { Accounting::Transaction.where(qb_id: qb_id).count }
          end

          it "updates transaction timestamp" do
            expect { subject.update }.to change { Accounting::Transaction.where(qb_id: qb_id).take.updated_at }
          end

          it "updates transaction fields" do
            subject.update
            t = Accounting::Transaction.where(qb_id: qb_id).take

            expect(t.quickbooks_data).to eq(quickbooks_data)
          end
        end

        context "with deleted JournalEntry" do
          let(:journal_entry) { instance_double(Quickbooks::Model::ChangeModel, id: qb_id, status: "Deleted") }

          it "destroys transaction with the proper qb_id" do
            expect { subject.update }.to change { Accounting::Transaction.where(qb_id: qb_id).count }.by(-1)
          end
        end
      end
    end
  end

  describe "extract_qb_data" do
    let(:txn) {
      build(:accounting_transaction, project: loan, quickbooks_data: quickbooks_data)
    }

    it "data persists from the extractor to the updater" do
      # the quickbooks_data variable matches a repayment type
      txn.save(validate: false) # mimic create_or_update_from_qb_object in transaction model
      subject.send(:extract_qb_data, loan)
      expect(loan.transactions.first.reload.loan_transaction_type_value).to eq("repayment")
    end
  end
end
