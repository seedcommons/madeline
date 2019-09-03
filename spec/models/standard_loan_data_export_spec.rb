require 'rails_helper'

describe StandardLoanDataExport, type: :model do
  it "has a valid factory" do
    expect(build(:data_export)).to be_valid
  end

  describe "process_data" do
    describe "headers" do
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
        h_to_i = header_to_index(data)
        expect(data).not_to be nil
        loan_row = data[1]
        expect(loan_row[h_to_i['Loan ID']]).to eq loan.id
        expect(loan_row[h_to_i['Name']]).to eq loan.name
        expect(loan_row[h_to_i['Division']]).to eq loan.division.name
      end
    end

    describe "loans" do
      let!(:division) { create(:division, :with_accounts) }
      let(:loan0) { create(:loan, :active, division: division, rate: 3.0) }
      let!(:t0) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 10.00,
        project: loan0, txn_date: "2019-01-01", division: division) }
        let(:export) {
          create(:standard_loan_data_export, data: nil)
        }
      let!(:loan1) { create(:loan, :active, division: division, rate: 3.0) }
      let!(:loan2) { create(:loan, :active, division: division, rate: 3.0) }
      let!(:t2) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 20.55,
        project: loan2, txn_date: "2019-01-01", division: division) }
        let(:export) {
          create(:standard_loan_data_export, data: nil)
        }
      let!(:loan3) { create(:loan, :active, division: division, rate: 3.0) }
      let!(:t4) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 20.00,
        project: loan3, txn_date: "2019-01-01", division: division) }
        let(:export) {
          create(:standard_loan_data_export, data: nil)
        }

      it "should handle loans with and without transactions" do
        export.process_data
        data = export.reload.data
        h_to_i = header_to_index(data)
        expect(data.size).to eq 5
        expect(data[1][h_to_i["Sum of Disbursements"]]).to eq "10.0"
        expect(data[2][h_to_i["Sum of Disbursements"]]).to be_nil
        expect(data[3][h_to_i["Sum of Disbursements"]]).to eq "20.55"
        expect(data[4][h_to_i["Sum of Disbursements"]]).to eq 0
        expect(data[1][h_to_i["Sum of Repayments"]]).to eq 0
        expect(data[2][h_to_i["Sum of Repayments"]]).to be_nil
        expect(data[3][h_to_i["Sum of Repayments"]]).to eq 0
        expect(data[4][h_to_i["Sum of Repayments"]]).to eq "20.0"
      end
    end


  end

  def header_to_index(data)
    headers = data[0]
    header_to_index = {}
    headers.each_with_index{|h, i| header_to_index[h] = i}
    header_to_index
  end


end
