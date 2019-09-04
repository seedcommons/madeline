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
      let(:export) {
        create(:standard_loan_data_export, data: nil, start_date: Date.parse('2018-12-31'), end_date: Date.parse('2019-01-31'))
      }
      let!(:division) { create(:division, :with_accounts) }
      let(:loan0) { create(:loan, :active, division: division, rate: 3.0) }
      let!(:t0) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 10.00,
        project: loan0, txn_date: "2019-01-01", division: division, change_in_interest: 0.1, change_in_principal: 1) }
      let!(:loan1) { create(:loan, :active, division: division, rate: 3.0) }
      let!(:loan2) { create(:loan, :active, division: division, rate: 3.0) }
      let!(:t2) { create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 20.55,
        project: loan2, txn_date: "2019-01-01", division: division, change_in_interest: 0.2, change_in_principal: 2) }
      let!(:loan3) { create(:loan, :active, division: division, rate: 3.0) }
      let!(:t4) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 20.00,
        project: loan3, txn_date: "2019-01-01", division: division, change_in_interest: 0.3, change_in_principal: 3) }
      let!(:t5) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 50.00,
        project: loan3, txn_date: "2018-12-01", division: division, change_in_interest: 0.5, change_in_principal: 5) }
      let!(:t6) { create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 60.00,
          project: loan3, txn_date: "2019-02-01", division: division, change_in_interest: 0.6, change_in_principal: 6) }


      it "should handle loans with and without transactions and respects date range" do
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
        expect(data[1][h_to_i["Change in Interest"]]).to eq "0.1"
        expect(data[2][h_to_i["Change in Interest"]]).to be_nil
        expect(data[3][h_to_i["Change in Interest"]]).to eq "0.2"
        expect(data[4][h_to_i["Change in Interest"]]).to eq "0.3"
        expect(data[1][h_to_i["Change in Principal"]]).to eq "1.0"
        expect(data[2][h_to_i["Change in Principal"]]).to be_nil
        expect(data[3][h_to_i["Change in Principal"]]).to eq "2.0"
        expect(data[4][h_to_i["Change in Principal"]]).to eq "3.0"
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
