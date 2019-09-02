require 'rails_helper'

describe StandardLoanDataExport, type: :model do
  it "has a valid factory" do
    expect(build(:data_export)).to be_valid
  end

  describe "process_data" do
    let!(:division) { create(:division, :with_accounts) }
    let(:loan) { create(:loan, :active, division: division, rate: 3.0) }
    let!(:t0) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 100.0,
      project: loan, txn_date: "2019-01-01", division: division) }
      let(:export) {
        create(:standard_loan_data_export, data: nil)
      }

    it "should create data attr with correct headers" do
      export.process_data
      data = export.reload.data
      expect(data).not_to be nil
      loan_row = data[1]
      expect(loan_row[0]).to eq loan.id
      expect(loan_row[1]).to eq loan.name
      expect(loan_row[2]).to eq loan.division.name
    end
  end


end
