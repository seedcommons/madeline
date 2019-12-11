# Customer in QB = Organization (Coop) in Madeline
#
# Represents a QB Customer object and can create a reference object
# for a link to this object in a transaction or other QB object.
module Accounting
  module Quickbooks
    class CustomerOld
      attr_reader :qb_connection, :organization

      def initialize(qb_connection:, organization:)
        @qb_connection = qb_connection
        @organization = organization
      end

      # We may be creating a customer here if needed. We return the qb_id and manualy create a reference.
      # The gem does not implement a helper method for _id like account or class.
      def reference
        qb_customer_id = find_or_create_qb_customer_id

        entity = ::Quickbooks::Model::Entity.new
        entity.type = 'Customer'
        entity_ref = ::Quickbooks::Model::BaseReference.new(qb_customer_id)
        entity.entity_ref = entity_ref

        organization.update!(qb_id: qb_customer_id)

        entity
      end

      private

      def service
        @service ||= ::Quickbooks::Service::Customer.new(qb_connection.auth_details)
      end

      def create_qb_customer_in_qb(qb_display_name)
        qb_customer = ::Quickbooks::Model::Customer.new
        qb_customer.display_name = qb_display_name
        service.create(qb_customer)
      end

      # Here there are two cases where we create the new customer in qb with a name different than the Madeline org name:
      # a) the name contains invalid characters or b) the name is already taken in qb by some entity other than customer.
      # we depend on the fact that the qb_id is saved in Madeline when the qb customer is created,
      # and that the id, not the org name, is used to identify the qb customer in the future.
      def find_or_create_qb_customer_id
        return organization.qb_id if organization.qb_id.present?
        normalized_name = organization.name.tr(':', '_')
        begin
          query_result = service.find_by(:display_name, "#{normalized_name.gsub("'", "\\\\'")}")
          if query_result.entries.empty?
            new_qb_customer = create_qb_customer_in_qb(normalized_name)
            new_qb_customer.id
          else
            query_result.entries.first.id
          end
        rescue ::Quickbooks::IntuitRequestException => e
          if e.message =~ /^Duplicate Name Exists Error/
            # we know duplicate is not customer bc was not found above (it is a vendor or other entity)
            normalized_customer_name = "#{normalized_name} (Customer)"
            new_qb_customer = create_qb_customer_in_qb(normalized_customer_name)
            new_qb_customer.id
          else
            raise e
          end
        end
      end
    end
  end
end
