module Accounting
  module Quickbooks
    class AccountFetcher
      attr_reader :qb_connection

      def initialize(qb_connection = Division.root.qb_connection)
        @qb_connection = qb_connection
      end

      def fetch
        service.all.each do |qb_object|
          find_or_create_account(qb_object: qb_object)
        end
      end

      private

      def find_or_create_account(qb_object:)
        acc_transaction = Accounting::Account
          .create_with(name: qb_object.name)
          .find_or_create_by(qb_id: qb_object.id)

        acc_transaction.update_attributes!(quickbooks_data: qb_object.as_json, name: qb_object.name)
      end

      def service
        ::Quickbooks::Service::Account.new(auth_details)
      end

      def auth_details
        { access_token: qb_connection.access_token, company_id: qb_connection.realm_id }
      end
    end
  end
end
