# frozen_string_literal: true

module Accounting
  module Quickbooks
    # Extract JournalEntry format quickbook transactions
    class BillExtractor < PurchaseExtractor
      attr_accessor :line_items
      delegate :qb_division, to: :loan

      def extract_account
        id = txn.quickbooks_data["ap_account_ref"]["value"]
        txn.account = Account.find(id)
      end
    end
  end
end
