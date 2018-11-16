# frozen_string_literal: true

module Accounting
  module Quickbooks
    # Extract Bill format quickbook transactions
    class BillExtractor < PurchaseExtractor
      attr_accessor :line_items
      delegate :qb_division, to: :loan

      def extract_account
        qb_id = txn.quickbooks_data["ap_account_ref"]["value"]
        txn.account = Accounting::Account.find_by(qb_id: qb_id)
      end
    end
  end
end
