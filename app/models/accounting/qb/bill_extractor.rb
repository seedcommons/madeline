# frozen_string_literal: true

module Accounting
  module QB
    # Extract Bill format quickbook transactions
    class BillExtractor < PurchaseExtractor
      attr_accessor :line_items
      delegate :qb_division, to: :loan

      protected

      def account_qb_id
        txn.quickbooks_data["ap_account_ref"]["value"]
      end
    end
  end
end
