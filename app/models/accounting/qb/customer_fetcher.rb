module Accounting
  module QB
    # Responsible for grabbing all quickbooks customers and inserting or updating Accounting::Customer
    class CustomerFetcher < FetcherBase
      def types
        [Accounting::Customer::QB_OBJECT_TYPE]
      end

      def find_or_create(qb_object_type:, qb_object:)
        Accounting::Customer.create_or_update_from_qb_object!(
          qb_object_type: qb_object_type,
          qb_object: qb_object
        )
      end
    end
  end
end
