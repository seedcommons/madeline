module Accounting
  module Quickbooks
    class FetchError < StandardError; end

    # This class is responsible for batching up Quickbooks API calls into separate types.
    # The API does support batch requests for queries, but quickbooks-ruby does not.
    class FetcherBase
      attr_reader :qb_connection

      def initialize(qb_connection = Division.root.qb_connection)
        @qb_connection = qb_connection
      end

      def fetch
        types.each do |type|
          results = service(type).all || []
          results.each do |qb_object|
            find_or_create(qb_object: qb_object)
          end
        end
      end

      private

      def find_or_create(qb_object:)
        raise NotImplementedError
      end

      def populate(qb_objects)
        @relation.each do |transaction|
          qb = qb_objects.find { |qbo| qbo.id.to_s == transaction.qb_transaction_id }
          transaction.qb_object = qb
        end
        @relation
      end

      def types
        raise NotImplementedError
      end

      def service(type)
        ::Quickbooks::Service.const_get(type).new(@qb_connection.auth_details)
      end
    end
  end
end
