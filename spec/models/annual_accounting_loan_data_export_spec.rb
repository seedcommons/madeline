require 'rails_helper'

describe AnnualAccountingLoanDataExport, type: :model do
  before do
    OptionSetCreator.new.create_loan_status
  end

  describe "process_data" do
    let(:start_date) { Date.parse("2019-07-01") }
    let(:end_date) { Date.parse("2021-06-30") }
    let!(:division) { create(:division, :with_accounts, closed_books_date: end_date + 1.year) }
    let(:loan) { create(:loan, :active, division: division, rate: 3.0) }
    let!(:excluded_disbursement) {
      create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 100.00,
                                      project: loan, txn_date: "2019-01-01", division: division, change_in_interest: 0, change_in_principal: 100,
                                      interest_balance: 0, principal_balance: 100)
    }
    let!(:disbursement_1) {
      create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 200.00,
                                      project: loan, txn_date: "2019-08-01", division: division, change_in_interest: 0, change_in_principal: 200,
                                      interest_balance: 0, principal_balance: 300)
    }
    let!(:interest_1) {
      create(:accounting_transaction, loan_transaction_type_value: "interest", amount: 9,
                                      project: loan, txn_date: "2019-08-31", division: division, change_in_interest: 9, change_in_principal: 0,
                                      interest_balance: 9, principal_balance: 300)
    }
    let!(:repayment_1) {
      create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 5.00,
                                      project: loan, txn_date: "2019-09-01", division: division, change_in_interest: -5, change_in_principal: 0,
                                      interest_balance: 4, principal_balance: 300)
    }
    let!(:disbursement_2) {
      create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 300.00,
                                      project: loan, txn_date: "2020-08-01", division: division, change_in_interest: 0, change_in_principal: 300,
                                      interest_balance: 4, principal_balance: 600)
    }
    let!(:interest_2) {
      create(:accounting_transaction, loan_transaction_type_value: "interest", amount: 9,
                                      project: loan, txn_date: "2020-08-31", division: division, change_in_interest: 18, change_in_principal: 0,
                                      interest_balance: 22, principal_balance: 600)
    }
    let!(:repayment_2) {
      create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 100.00,
                                      project: loan, txn_date: "2020-09-01", division: division, change_in_interest: -22, change_in_principal: -78,
                                      interest_balance: 0, principal_balance: 522)
    }
    let!(:disbursement_3) {
      create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 400.00,
                                      project: loan, txn_date: "2021-01-01", division: division, change_in_interest: 0, change_in_principal: 400,
                                      interest_balance: 0, principal_balance: 922)
    }
    let!(:interest_3) {
      create(:accounting_transaction, loan_transaction_type_value: "interest", amount: 19,
                                      project: loan, txn_date: "2021-01-31", division: division, change_in_interest: 19, change_in_principal: 0,
                                      interest_balance: 19, principal_balance: 922)
    }
    let!(:repayment_3) {
      create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 200.00,
                                      project: loan, txn_date: "2021-03-01", division: division, change_in_interest: -19, change_in_principal: -81,
                                      interest_balance: 0, principal_balance: 841)
    }
    let!(:excluded_repayment) {
      create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 100.00,
                                      project: loan, txn_date: "2021-11-01", division: division,  change_in_interest: 0, change_in_principal: -100,
                                      interest_balance: 0, principal_balance: 941)
    }

    let(:export) { create(:annual_accounting_loan_data_export, data: nil, start_date: start_date, end_date: end_date) }

    let(:loan_1_numbers) { [loan.id, "200.0", "5.0", "9.0", "300.0", "100.0", "18.0", "400.0", "200.0", "19.0", "900.0", "305.0", "46.0", "841.0", "0.0", "841.0"] }

    it "should create data attr with correct headers" do
      export.process_data
      puts export.class
      data = export.reload.data
      # expect(data[0]).to eq ["Loan Id",
      #   "Disbursements 2019-07-01 - 2019-12-31",
      #   "Repayments 2019-07-01 - 2019-12-31",
      #   "Interest Accrued 2019-07-01 - 2019-12-31",
      #   "Disbursements 2020",
      #   "Repayments 2020",
      #   "Interest Accrued 2020",
      #   "Disbursements 2021-01-01 - 2021-06-30",
      #   "Repayments 2021-01-01 - 2021-06-30",
      #   "Interest Accrued 2021-01-01 - 2021-06-30",
      #   "Total Disbursements 2019-07-01 - 2021-06-30",
      #   "Total Repayments 2019-07-01 - 2021-06-30",
      #   "Total Interest Accrued 2019-07-01 - 2021-06-30",
      #   "Principal Balance 2021-06-30",
      #   "Interest Balance 2021-06-30",
      #   "Total Balance 2021-06-30"
      #   ]
      # expect(data[1]).to eq [
      #   "loan_id",
      #   "2019_sum_disbursements",
      #   "2019_sum_repayments",
      #   "2019_interest_accrued",
      #   "2020_sum_disbursements",
      #   "2020_sum_repayments",
      #   "2020_interest_accrued",
      #   "2021_sum_disbursements",
      #   "2021_sum_repayments",
      #   "2021_interest_accrued",
      #   "total_sum_disbursements",
      #   "total_sum_repayments",
      #   "total_interest_accrued",
      #   "end_principal_balance",
      #   "end_interest_balance",
      #   "end_total_balance"
      # ]
      expect(data[2]).to eq loan_1_numbers
    end
  end
end
