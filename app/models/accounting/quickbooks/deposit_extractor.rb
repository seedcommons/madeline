# frozen_string_literal: true

module Accounting
  module Quickbooks
    # Extract JournalEntry format quickbook transactions
    class DepositExtractor < TransactionExtractor
      attr_accessor :line_items
      delegate :qb_division, to: :loan

      def set_type
        txn.loan_transaction_type_value = 'repayment'
      end

      def set_managed
        txn.managed = doc_number_includes('MS-Managed') || doc_number_includes('MS-Automatic')
      end

      def extract_account
        id = txn.quickbooks_data["deposit_to_account_ref"]["value"]
        txn.account = Account.find(id)
      end

      def extract_line_items
        txn.quickbooks_data['line_items'].each do |li|
          txn.line_item_with_id(li['id'].to_i).assign_attributes(
            amount: li['amount'],
            posting_type: li[qb_li_detail_key]['posting_type'],
            description: li['description']
          )
        end
        txn.txn_date = txn.quickbooks_data['txn_date']
        txn.private_note = txn.quickbooks_data['private_note']
        txn.total = txn.quickbooks_data['total']
        txn.currency = lookup_currency
      end

      def add_implicit_line_items
        txn.line_items << LineItem.new(
          account: txn.account,
          amount: txn.amount,
          posting_type: 'Debit'
        )
      end

      # Using total assumes that all line items in txn are for accts in Madeline.
      # This assumption is safe because we never push amount to QB.
      def calculate_amount
        txn.amount = txn.total
      end

      def qb_li_detail_key
        'deposit_line_detail'
      end
    end
  end
end
