module Accounting
  module QB

    # Responsible for grabbing all quickbooks accounts and inserting or updating Accounting::Account
    class TransactionFetcher < FetcherBase
      def types
        Accounting::Transaction::QB_OBJECT_TYPES
      end

      def find_or_create(qb_object_type:, qb_object:)
        Accounting::Transaction.create_or_update_from_qb_object!(
          qb_object_type: qb_object_type,
          qb_object: qb_object
        )
      end
    end
  end
end
