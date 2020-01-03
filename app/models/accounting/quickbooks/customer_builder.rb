module Accounting
  module Quickbooks
    class CustomerBuilder
      attr_reader :qb_division, :qb_connection, :principal_account

      def initialize(qb_division = Division.root)
        @qb_division = qb_division
        @qb_connection = qb_division.qb_connection
        @principal_account = qb_division.principal_account
      end

      # Assumes customer with org name is not already in Accounting::Customer table
      def new_accounting_customer_for(organization)
        find_or_create_customer_in_qb(organization.name)
        Accounting::Customer.find_by(name: organization.name)
      end

      private

      def service
        @service ||= ::Quickbooks::Service::Customer.new(qb_connection.auth_details)
      end

      # There are two cases where we create the new customer in qb with a name different than the Madeline org name:
      # a) the name contains invalid characters or b) the name is already taken in qb by some entity other than customer.
      # we depend on the fact that the qb_id is saved in Madeline when the qb customer is created,
      # and that the id, not the org name, is used to identify the qb customer in the future.
      def find_or_create_customer_in_qb(name)
        normalized_name = name.tr(':', '_')
        # Look at existing customers in qb (for case that Accounting::Customer table is stale)
        begin
          query_result = service.find_by(:display_name, "#{normalized_name.gsub("'", "\\\\'")}")
          if query_result.entries.empty?
            create_customer_in_qb(normalized_name)
          else
            Accounting::Customer.create_or_update_from_qb_object!('Customer', query_result.entries.first)
          end
        rescue ::Quickbooks::IntuitRequestException => e
          if e.message =~ /^Duplicate Name Exists Error/
            # we know duplicate is not customer bc was not found above (it is a vendor or other entity)
            normalized_customer_name = "#{normalized_name} (Customer)"
            create_customer_in_qb(normalized_customer_name)
          else
            raise e
          end
        end
      end

      def create_customer_in_qb(qb_display_name)
        qb_customer = ::Quickbooks::Model::Customer.new
        qb_customer.display_name = qb_display_name
        new_qb_customer = service.create(qb_customer)
        Accounting::Customer.create_or_update_from_qb_object!('Customer', new_qb_customer)
      end
    end
  end
end
