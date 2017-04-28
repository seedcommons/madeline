module Accounting
  module Quickbooks

    # Responsible for grabbing all quickbooks accounts and inserting or updating Accounting::Account
    class TransactionFetcher < FetcherBase
      def types
        Accounting::Transaction::QB_TRANSACTION_TYPES
      end

      def find_or_create(qb_object:)
        Accounting::Transaction.find_or_create_from_qb_object qb_object
      end
    end
  end
end
