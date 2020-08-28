module Accounting
  module QB

    # Responsible for grabbing all quickbooks accounts and inserting or updating Accounting::Account
    class AccountFetcher < FetcherBase
      def types
        [Accounting::Account::QB_OBJECT_TYPE]
      end

      def find_or_create(qb_object_type:, qb_object:)
        Accounting::Account.create_or_update_from_qb_object!(
          qb_object_type: qb_object_type,
          qb_object: qb_object
        )
      end
    end
  end
end
