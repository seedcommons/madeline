module Accounting
  module Quickbooks
    class Fetcher
      def initialize(relation)
        @relation = relation
      end

      def query
        util = ::Quickbooks::Util::QueryBuilder.new

        types.map do |type|
          q = "select * from #{type} where #{util.clause('Id', 'in', ids)}"
          service(type).query(q).entries
        end.flatten
      end

      def populate(qb_objects)
        @relation.each do |transaction|
          qb = qb_objects.find { |qbo| qbo.id.to_s == transaction.qb_transaction_id }
          transaction.qb_object = qb
        end
        @relation
      end

      def fetch
        qb_objects = query
        populate(qb_objects)
      end

      private

      def ids
        @relation.pluck(:qb_transaction_id)
      end

      def types
        @relation.distinct(:qb_transaction_type).pluck(:qb_transaction_type)
      end

      def service(type)
        ::Quickbooks::Service.const_get(type).new(auth_details)
      end

      def auth_details
        { access_token: qb_connection.access_token, company_id: qb_connection.realm_id }
      end

      def qb_connection
        @qb_connection ||= Division.root.qb_connection
      end
    end
  end
end
