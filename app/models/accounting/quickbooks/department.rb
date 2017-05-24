module Accounting
  module Quickbooks

    # Represents a QBO Department object and can create a reference object
    # for a link to this object in a transaction or other QBO object.
    class Department
      attr_reader :qb_connection, :division

      def initialize(qb_connection:, division:)
        @qb_connection = qb_connection
        @division = division
      end

      # We may be creating a department here if needed. We return the qb_id and manualy create a reference.
      # The gem does not implement a helper method for _id like account or class.
      def reference
        qb_department_id = find_or_create_qb_department_id

        entity_ref = ::Quickbooks::Model::BaseReference.new(qb_department_id)

        division.update!(qb_id: qb_department_id)

        entity_ref
      end

      private

      def service
        @service ||= ::Quickbooks::Service::Department.new(qb_connection.auth_details)
      end

      def find_or_create_qb_department_id
        return division.qb_id if division.qb_id.present?

        qb_department = ::Quickbooks::Model::Department.new
        qb_department.name = division.name

        new_qb_department = service.create(qb_department)

        new_qb_department.id
      end
    end
  end
end
