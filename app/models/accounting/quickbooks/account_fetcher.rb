module Accounting
  module Quickbooks

    # Responsible for grabbing all quickbooks accounts and inserting or updating Accounting::Account
    class AccountFetcher < FetcherBase
      def types
        [Accounting::Account::QB_TRANSACTION_TYPE]
      end

      def find_or_create(transaction_type:, qb_object:)
        Accounting::Account.find_or_create_from_qb_object transaction_type: transaction_type, qb_object: qb_object
      end
    end
  end
end
