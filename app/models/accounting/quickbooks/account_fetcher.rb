module Accounting
  module Quickbooks
    class AccountFetcher < FetcherBase
      def types
        ['Account']
      end

      def find_or_create(transaction_type:, qb_object:)
        acc_transaction = Accounting::Account.create_with(name: qb_object.name).find_or_create_by qb_id: qb_object.id
        acc_transaction.update_attributes!(name: qb_object.name, qb_account_classification: qb_object.classification, quickbooks_data: qb_object.as_json)
      end
    end
  end
end
