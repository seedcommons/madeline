module Accounting
  module Quickbooks
    # This class is responsible for batching up Quickbooks API calls into separate types.
    # The API does support batch requests for queries, but quickbooks-ruby does not.
    class TransactionFetcher
      attr_reader :qb_connection

      def initialize(qb_connection = Division.root.qb_connection)
        @qb_connection = qb_connection
      end

      def fetch
        types.each do |type|
          service(type).all.each do |qb_object|
            find_or_create_transaction(transaction_type: type, qb_object: qb_object)
          end
        end
      end

      private

      def find_or_create_transaction(transaction_type:, qb_object:)
        acc_transaction = Accounting::Transaction.find_or_create_by qb_transaction_type: transaction_type, qb_id: qb_object.id
        acc_transaction.update_attributes!(quickbooks_data: qb_object.as_json)
      end

      def populate(qb_objects)
        @relation.each do |transaction|
          qb = qb_objects.find { |qbo| qbo.id.to_s == transaction.qb_transaction_id }
          transaction.qb_object = qb
        end
        @relation
      end

      def ids
        @relation.pluck(:qb_transaction_id)
      end

      def types
        Accounting::Transaction::TRANSACTION_TYPES
      end

      def service(type)
        ::Quickbooks::Service.const_get(type).new(auth_details)
      end

      def auth_details
        { access_token: qb_connection.access_token, company_id: qb_connection.realm_id }
      end
    end
  end
end
