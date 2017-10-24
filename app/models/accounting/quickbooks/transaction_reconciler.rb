module Accounting
  module Quickbooks
    # Responsible for creating transaction entries in quickbooks.
    class TransactionReconciler
      attr_reader :qb_connection, :principal_account

      def initialize(root_division = Division.root)
        @qb_connection = root_division.qb_connection
        @principal_account = root_division.principal_account
      end

      # Creates a transaction in Quickbooks based on a Transaction object created in Madeline. Line
      # items in QB mirror line items in Madeline.
      def reconcile(transaction)
        return unless transaction.present?

        if transaction.qb_id.present?
          service.update(transaction)
        else
          service.create(transaction)
        end
      end

      private

      def service
        @service ||= ::Quickbooks::Service::JournalEntry.new(qb_connection.auth_details)
      end
    end
  end
end
