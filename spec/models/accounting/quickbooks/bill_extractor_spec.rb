require 'rails_helper'

describe Accounting::Quickbooks::BillExtractor, type: :model do
  let(:qb_id) { 1982547353 }
  let(:division) { create(:division, :with_accounts) }
  let(:prin_acct) { division.principal_account }
  let(:int_inc_acct) { division.interest_income_account }
  let(:int_rcv_acct) { division.interest_receivable_account }
  let(:txn_acct) { create(:account, name: 'Some Bank Account') }
  let(:random_acct) { create(:account, name: 'Another Bank Account') }
  let(:loan) { create(:loan, division: division) }

  # This is example bill JSON that might be returned by the QB API.
  let(:quickbooks_data) do
    {
      "line_items":
        [
          {
            "id": "1",
            "line_num": nil,
            "description": "stuff",
            "amount": "32476.1",
            "detail_type": "AccountBasedExpenseLineDetail",
            "account_based_expense_line_detail": {
              "customer_ref": nil,
              "class_ref": {
                "value": "2000000000003635778",
                "name": "Name",
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
            "item_based_expense_line_detail": nil
          },
          {
            "id": "2",
            "line_num": nil,
            "description": "Desc",
            "amount": "-641.0",
            "detail_type": "AccountBasedExpenseLineDetail",
            "account_based_expense_line_detail": {
              "customer_ref": nil,
              "class_ref": {
                "value": "400000000003634837",
                "name": "Other stuff",
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
            "item_based_expense_line_detail": nil
          },
          {
            "id": "3",
            "line_num": nil,
            "description": "Desc",
            "amount": "29.35",
            "detail_type": "AccountBasedExpenseLineDetail",
            "account_based_expense_line_detail": {
            "customer_ref": nil,
            "class_ref": {
              "value": "2000000000003635778",
              "name": "Name",
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
           "item_based_expense_line_detail": nil
          }
        ],
      "global_tax_calculation": nil,
      "id": "16788",
      "sync_token": 2,
      "meta_data": {
        "create_time": "2018-07-17T16:27:28.000-07:00",
        "last_updated_time": "2018-07-17T16:38:06.000-07:00"
      },
      "doc_number": "667",
      "txn_date": "2018-04-13",
      "department_ref": nil,
      "private_note": nil,
      "vendor_ref": {
        "value": "3637",
        "name": "Vendor",
        "type": nil
      },
      "payer_ref": nil,
      "sales_term_ref": {
        "value": "31",
        "name": nil,
        "type": nil
      },
      "attachable_ref": nil,
      "ap_account_ref": {
      "value": txn_acct.qb_id,
        "name": "Accounts Payable",
        "type": nil
      },
      "due_date": "2018-5-13",
      "remit_to_address": nil,
      "ship_address": nil,
      "exchange_rate": nil,
      "balance": "0.0",
      "bill_email": nil,
      "reply_email": nil,
      "total": "20527.35",
      "currency_ref": {
        "value": "USD",
        "name": "United States Dollar",
        "type": nil
      }
    }
  end

  context 'extract!' do
    it 'updates correctly in Madeline' do
      txn = create(:accounting_transaction, project: loan, quickbooks_data: quickbooks_data)
      Accounting::Quickbooks::BillExtractor.new(txn).extract!
      expect(txn.loan_transaction_type_value).to eq 'disbursement'
      expect(txn.managed).to be false
      expect(txn.line_items.size).to eq 4
      expect(txn.line_items.last.account).to eq txn.account
      expect(txn.line_items.last.credit?).to be true
      expect(txn.account).to eq txn_acct
      expect(txn.amount).to equal_money(20527.35)
    end
  end
end
