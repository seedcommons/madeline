module Accounting
  module Quickbooks
    # Responsible for updating or creating transaction entries in quickbooks.
    class TransactionReconciler
      attr_reader :qb_connection, :principal_account, :root_division

      def initialize(root_division = Division.root)
        @root_division = root_division
        @qb_connection = root_division.qb_connection
        @principal_account = root_division.principal_account
      end

      # Creates a transaction in Quickbooks based on a Transaction object created in Madeline. Line
      # items in QB mirror line items in Madeline.
      def reconcile(transaction)
        return unless transaction.present?

        je = builder.build_for_qb(transaction)

        if transaction.qb_id.present?
          service.update(je)
        else
          service.create(je)
        end

        je
      end

      private

      def builder
        @builder ||= TransactionBuilder.new(root_division)
      end

      def service
        @service ||= ::Quickbooks::Service::JournalEntry.new(qb_connection.auth_details)
      end
    end
  end
end
