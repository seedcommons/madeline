require "rails_helper"

RSpec.describe Accounting::Transaction, type: :model do
  let(:division) { create(:division, :with_accounts) }
  let(:prin_acct) { division.principal_account }
  let(:int_inc_acct) { division.interest_income_account }
  let(:int_rcv_acct) { division.interest_receivable_account }
  let(:loan) { create(:loan, division: create(:division, :with_accounts)) }

  # This is example JSON that might be returned by the QB API.
  # The data are taken from the docs/example_calculation.xlsx file, row 7.
  let(:quickbooks_data) { create(:transaction_json, loan: loan) }

  describe ".standard_order" do
    let!(:txn_1) do
      create(:accounting_transaction,
             txn_date: Date.today,
             loan_transaction_type_value: "repayment",
             created_at: Time.now - 1.minute)
    end
    let!(:txn_2) do
      create(:accounting_transaction,
             txn_date: Date.today,
             loan_transaction_type_value: "disbursement",
             created_at: Time.now - 2.minutes)
    end
    let!(:txn_3) do
      create(:accounting_transaction,
             txn_date: Date.today - 3,
             loan_transaction_type_value: "disbursement",
             created_at: Time.now - 3.minutes)
    end
    let!(:txn_4) do
      create(:accounting_transaction,
             txn_date: Date.today - 3,
             loan_transaction_type_value: "interest",
             created_at: Time.now - 10.minutes)
    end
    let!(:txn_5) do
      create(:accounting_transaction,
             txn_date: Date.today - 3,
             loan_transaction_type_value: "interest",
             created_at: Time.now - 5.minutes)
    end

    before do
      OptionSetCreator.new.create_loan_transaction_type
    end

    it "returns in the right order" do
      expect(Accounting::Transaction.standard_order).to eq([txn_4, txn_5, txn_3, txn_2, txn_1])
    end
  end

  describe ".create_or_update_from_qb_object!" do
    it "should set appropriate fields on create" do
      qb_obj = double(id: 123, as_json: {"x" => "y"})
      txn = described_class.create_or_update_from_qb_object!(qb_object_type: "JournalEntry", qb_object: qb_obj)

      expect(txn.qb_object_type).to eq("JournalEntry")
      expect(txn.qb_id).to eq("123")
      expect(txn.quickbooks_data).to eq({"x" => "y"})
      expect(txn.needs_qb_push).to be false
    end

    context "with other transaction types" do
      Accounting::Transaction::QB_OBJECT_TYPES.each do |type|
        let(:quickbooks_data) { create(:transaction_json, loan: loan, type: type) }

        it "associates QB #{type} txn with loan if there is a match" do
          qb_obj = double(id: 124, as_json: quickbooks_data)
          txn = described_class.create_or_update_from_qb_object!(qb_object_type: "Bill", qb_object: qb_obj)
          expect(txn.project_id).to eq(loan.id)
        end
      end
    end

    it "associates old QB txn with loan if there is a match" do
      qb_obj = double(id: 124, as_json: quickbooks_data)
      txn = described_class.create_or_update_from_qb_object!(qb_object_type: "JournalEntry", qb_object: qb_obj)

      expect(txn.project_id).to eq(loan.id)
    end
  end

  # TODO: this block of specs, and accompanying #set_qb_object_type logic needs review
  describe "sets qb txn type and requires amount on madeline-created disbursements" do
    let(:transaction_params) do
      {
        amount: nil,
        txn_date: "2017-10-31",
        private_note: "a memo",
        description: "desc",
        project_id: loan.id,
        loan_transaction_type_value: transaction_type
      }
    end

    context "when disbursement transaction" do
      let(:transaction_type) { "disbursement" }

      context "without qb_id" do
        it "requires an amount to save" do
          expect do
            create(:accounting_transaction, transaction_params.merge(qb_id: nil))
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "with qb_id" do
        it "requires an amount to save" do
          expect do
            create(:accounting_transaction, transaction_params.merge(qb_id: 123))
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      it "has qb object type purchase when new" do
        txn = Accounting::Transaction.new(transaction_params)
        txn.save
        expect(txn.reload.qb_object_type).to eq "Purchase"
      end

      it "has qb object type je if was je and has qb_id" do
        txn = Accounting::Transaction.new(transaction_params.merge(qb_id: "1", qb_object_type: "JournalEntry"))
        txn.save
        expect(txn.reload.qb_object_type).to eq "JournalEntry"
      end

      context "with type check" do
        let(:check_number) { 1 }
        let(:vendor_id) { 1 }
        let(:transaction_params) do
          {
            amount: 10,
            txn_date: "2017-10-31",
            private_note: "a memo",
            description: "desc",
            project_id: loan.id,
            loan_transaction_type_value: transaction_type,
            qb_object_subtype: "Check",
            qb_vendor_id: vendor_id,
            check_number: check_number
          }
        end

        context "no check number" do
          let(:check_number) { nil }
          it "requires a check number to save" do
            expect do
              create(:accounting_transaction, transaction_params.merge({user_created: true}))
            end.to raise_error(ActiveRecord::RecordInvalid)
          end
        end

        context "no vendor" do
          let(:vendor_id) { nil }
          it "requires a vendor to save when created by user" do
            expect do
              create(:accounting_transaction, transaction_params.merge({user_created: true}))
            end.to raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end
    end

    context "when interest transaction" do
      let(:transaction_type) { "interest" }

      context "without qb_id" do
        it "can save without amount" do
          expect do
            create(:accounting_transaction, transaction_params.merge(qb_id: nil))
          end.not_to raise_error
        end
      end
    end
  end

  context "with line items" do
    let(:transaction) { create(:accounting_transaction, project: loan) }
    let(:txn) { transaction }
    let(:int_inc_acct) { transaction.division.interest_income_account }
    let(:int_rcv_acct) { transaction.division.interest_receivable_account }
    let(:prin_acct) { transaction.division.principal_account }
    let!(:line_items) do
      create_line_item(txn, "Debit", 1.02, account: prin_acct)
      create_line_item(txn, "Debit", 2.07, account: int_rcv_acct)
      create_line_item(txn, "Debit", 1.50, account: int_inc_acct)
      create_line_item(txn, "Credit", 1.15, account: prin_acct)
      create_line_item(txn, "Credit", 3.00, account: int_rcv_acct)
      create_line_item(txn, "Credit", 1.25, account: int_inc_acct)

      # These are decoy line items associated with random accounts that we don't care about.
      # They should not be included in the change_in_* calculations.
      create_line_item(txn, "Debit", 2.50)
      create_line_item(txn, "Credit", 1.69)
    end

    describe "#change_in_principal and #change_in_interest" do
      it "calculates correctly" do
        transaction.calculate_deltas
        transaction.save
        expect(transaction.reload.change_in_principal).to equal_money(-0.13)
        expect(transaction.reload.change_in_interest).to equal_money(-0.93)
      end
    end

    describe "#calculate_balances" do
      it "works without previous transaction" do
        transaction.calculate_balances
        expect(transaction.principal_balance).to equal_money(-0.13)
        expect(transaction.interest_balance).to equal_money(-0.93)
      end

      it "works with previous transaction" do
        prev_tx = create(:accounting_transaction, principal_balance: 6.22, interest_balance: 4.50)

        transaction.calculate_balances(prev_tx: prev_tx)
        expect(transaction.principal_balance).to equal_money(6.09)
        expect(transaction.interest_balance).to equal_money(3.57)
      end
    end

    def create_line_item(txn, type, amount, options = {})
      create(:line_item, options.merge(parent_transaction: txn, posting_type: type, amount: amount))
    end
  end
end
