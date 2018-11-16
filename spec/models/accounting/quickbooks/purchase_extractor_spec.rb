require 'rails_helper'

describe Accounting::Quickbooks::PurchaseExtractor, type: :model do
  let(:qb_id) { 1982547353 }
  let(:division) { create(:division, :with_accounts) }
  let(:prin_acct) { division.principal_account }
  let(:int_inc_acct) { division.interest_income_account }
  let(:int_rcv_acct) { division.interest_receivable_account }
  let(:txn_acct) { create(:account, name: 'Some Bank Account') }
  let(:random_acct) { create(:account, name: 'Another Bank Account') }
  let(:loan) { create(:loan, division: division) }

  # This is example purchase JSON that might be returned by the QB API.
  let(:quickbooks_data) do
    {
      "line_items": [
        {
          "id": "1",
          "line_num": nil,
          "description": '#738209',
          "amount": "12345.67",
          "detail_type": "AccountBasedExpenseLineDetail",
          "account_based_expense_line_detail": {
            "customer_ref": {
              "value": "1414",
              "name": "Ice Cream Galor, LLC",
              "type": nil
            },
            "class_ref": {
              "value": loan.id,
              "name": loan.name,
              "type": nil
            },
            "account_ref": {
              "value": random_acct.qb_id,
              "name": random_acct.name,
              "type": nil
            },
            "billable_status": "NotBillable",
            "tax_amount": nil,
            "tax_code_ref": {
              "value": "NON",
              "name": nil,
              "type": nil
            }
          },
          "item_based_expense_line_detail": nil,
          "group_line_detail": nil
        }
      ],
      "global_tax_calculation": nil,
      "id": "23531",
      "sync_token": 1,
      "meta_data": {
        "create_time": "2018-05-03T13:37:22.000-07:00",
        "last_updated_time": "2018-06-13T12:52:22.000-07:00"
      },
      "doc_number": "5438",
      "txn_date": "2018-06-12",
      "private_note": nil,
      "account_ref": {
        "value": txn_acct.id,
        "name": txn_acct.name,
        "type": nil
      },
      "txn_tax_detail": nil,
      "payment_type": "Check",
      "entity_ref": {
        "value": "7893",
        "name": "ABC",
        "type": "Vendor"
      },
      "remit_to_address": nil,
      "total": "12345.67",
      "print_status": "NotSet",
      "department_ref": nil,
      "currency_ref": {
        "value": "USD",
        "name": "United States Dollar",
        "type": nil
      },
      "exchange_rate": nil,
      "linked_transactions": [],
      "credit": nil
    }
  end

  let(:txn) { create(:accounting_transaction, project: loan, quickbooks_data: quickbooks_data) }

  context 'extract!' do
    it 'updates correctly in Madeline' do
      Accounting::Quickbooks::PurchaseExtractor.new(txn).extract!
      expect(txn.loan_transaction_type_value).to eq 'disbursement'
      expect(txn.managed).to be false
      expect(txn.line_items.size).to eq 2
      expect(txn.line_items[0].description).to eq '#738209'
      expect(txn.line_items[1].account).to eq txn.account
      expect(txn.line_items[1].credit?).to be true
      expect(txn.account).to eq txn_acct
      expect(txn.amount).to equal_money(12345.67)
    end
  end
end
