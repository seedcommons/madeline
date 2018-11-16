require 'rails_helper'

describe Accounting::Quickbooks::DepositExtractor, type: :model do
  let(:qb_id) { 1982547353 }
  let(:division) { create(:division, :with_accounts) }
  let(:prin_acct) { division.principal_account}
  let(:int_inc_acct) { division.interest_income_account }
  let(:int_rcv_acct) { division.interest_receivable_account }
  let(:txn_acct) { create(:account, name: 'Some Bank Account') }
  let(:random_acct) { create(:account, name: 'Another Bank Account') }
  let(:loan) { create(:loan, division: division) }

  # This is example bill JSON that might be returned by the QB API.
  let(:quickbooks_data) do
    {
      "line_items": [{
        "id": "1",
        "line_num": 1,
        "description": "Description",
        "amount": "568.43",
        "linked_transactions": [],
        "detail_type": "DepositLineDetail",
        "deposit_line_detail": {
          "entity_ref": {
            "value": "5687",
            "name": "Name",
            "type": "CUSTOMER"
          },
          "class_ref": {
            "value": "6000000000000438270",
            "name": "Loan",
            "type": nil
          },
          "account_ref": {
            "value": "709",
            "name": "Loan Receivable",
            "type": nil
          },
          "payment_method_ref": nil,
          "check_num": "234",
          "txn_type": nil,
          "custom_fields": []
        },
        "custom_fields": []
      }, {
        "id": "2",
        "line_num": 2,
        "description": nil,
        "amount": "49.8",
        "linked_transactions": [],
        "detail_type": "DepositLineDetail",
        "deposit_line_detail": {
          "entity_ref": {
            "value": "5687",
            "name": "Name",
            "type": "CUSTOMER"
          },
          "class_ref": {
            "value": "6000000000000438270",
            "name": "Loan",
            "type": nil
          },
          "account_ref": {
            "value": "205",
            "name": "Accounts Receivable 123",
            "type": nil
          },
          "payment_method_ref": nil,
          "check_num": nil,
          "txn_type": nil,
          "custom_fields": []
        },
        "custom_fields": []
      }],
      "id": 25855,
      "sync_token": 1,
      "meta_data": {
        "create_time": "2018-05-13T14:31:09.000-07:00",
        "last_updated_time": "2018-05-13T14:32:27.000-07:00"
      },
      "custom_fields": [],
      "auto_doc_number": nil,
      "doc_number": nil,
      "txn_date": "2017-12-16",
      "department_ref": nil,
      "currency_ref": {
        "value": "USD",
        "name": "United States Dollar",
        "type": nil
      },
      "exchange_rate": nil,
      "private_note": "Description",
      "txn_status": nil,
      "txn_tax_detail": nil,
      "deposit_to_account_ref": {
        "value": txn_acct.id,
        "name": txn_acct.name,
        "type": nil
      },
      "total": "849.41"
    }
  end

  context 'extract!' do
    it 'updates correctly in Madeline' do
      txn = create(:accounting_transaction, project: loan, quickbooks_data: quickbooks_data)
      Accounting::Quickbooks::DepositExtractor.new(txn).extract!
      expect(txn.loan_transaction_type_value).to eq 'repayment'
      expect(txn.managed).to be false
      expect(txn.line_items.size).to eq 3
      expect(txn.line_items.last.account).to eq txn.account
      expect(txn.line_items.last.amount).to eq txn.amount
      expect(txn.line_items.last.debit?).to be true
      expect(txn.account).to eq txn_acct
      expect(txn.amount).to equal_money(849.41)
    end
  end
end
