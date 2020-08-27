module Accounting
  module QB
    # Responsible for grabbing all quickbooks vendors and inserting or updating Accounting::Customer
    class VendorFetcher < FetcherBase
      def types
        [Accounting::QB::Vendor::QB_OBJECT_TYPE]
      end

      def find_or_create(qb_object_type:, qb_object:)
        Accounting::QB::Vendor.create_or_update_from_qb_object!(
          qb_object_type: qb_object_type,
          qb_object: qb_object
        )
      end
    end
  end
end
