module Accounting
  module Quickbooks
    class TransactionFetcher < FetcherBase
      def types
        Accounting::Transaction::QB_TRANSACTION_TYPES
      end

      def find_or_create(transaction_type:, qb_object:)
        acc_transaction = Accounting::Transaction.find_or_create_by qb_transaction_type: transaction_type, qb_id: qb_object.id
        acc_transaction.update_attributes!(quickbooks_data: qb_object.as_json)
      end
    end
  end
end
