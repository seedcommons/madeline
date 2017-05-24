module Accounting
  module Quickbooks

    # Represents a QBO Customer object and can create a reference object
    # for a link to this object in a transaction or other QBO object.
    class Customer
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

        entity
      end

      private

      def service
        @service ||= ::Quickbooks::Service::Customer.new(qb_connection.auth_details)
      end

      def find_or_create_qb_customer_id
        return organization.qb_id if organization.qb_id.present?

        qb_customer = ::Quickbooks::Model::Customer.new
        qb_customer.display_name = organization.name

        new_qb_customer = service.create(qb_customer)

        new_qb_customer.id
      end
    end
  end
end
