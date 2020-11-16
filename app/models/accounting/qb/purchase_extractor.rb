# frozen_string_literal: true

module Accounting
  module QB
    # Extract Purchase format quickbook transactions
    class PurchaseExtractor < TransactionExtractor
      attr_accessor :line_items
      delegate :qb_division, to: :loan

      def set_type
        txn.loan_transaction_type_value = 'disbursement'
      end

      def extract_account
        qb_id = txn.quickbooks_data["account_ref"]["value"]
        txn.account = Accounting::Account.find_by(qb_id: qb_id)
      end

      def extract_subtype
        payment_type = txn.quickbooks_data["payment_type"]
        txn.qb_object_subtype = payment_type.to_s if payment_type.present?
      end

      def extract_check_number
        if txn.subtype?("Check")
          doc_number = txn.quickbooks_data["doc_number"]
          txn.check_number = doc_number.remove("MS-Managed").strip if doc_number.present?
        end
      end

      def extract_customer
        @line_items = txn.quickbooks_data["line_items"]
        li = @line_items.first unless @line_items.empty?
        details = li[qb_li_detail_key] if li
        customer_ref = details['customer_ref'] if details
        return if customer_ref.nil?
        txn.customer = Accounting::Customer.find_by(qb_id: customer_ref['value'])
      end

      def extract_vendor
        vendor_ref = txn.quickbooks_data['entity_ref']
        return if vendor_ref.nil?
        vendor_qb_id = vendor_ref['value']
        txn.vendor = Accounting::QB::Vendor.find_by(qb_id: vendor_qb_id)
      end

      # Using total assumes that all line items in txn are for accts in Madeline.
      # This assumption is safe because we never push amount to QB.
      def calculate_amount
        txn.amount = txn.total
      end

      def add_implicit_line_items
        txn.line_items << LineItem.new(
          account: txn.account,
          amount: txn.amount,
          posting_type: 'Credit'
        )
      end

      def existing_li_posting_type
        "Debit"
      end

      def qb_li_detail_key
        "account_based_expense_line_detail"
      end

      def set_managed
        txn.managed = txn.loan_transaction_type_value != "other" && (doc_number_includes('MS-Managed') || doc_number_includes('MS-Automatic'))
      end
    end
  end
end
