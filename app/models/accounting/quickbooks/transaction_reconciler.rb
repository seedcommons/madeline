# Responsible for updating or creating transaction entries in Quickbooks.
module Accounting
  module Quickbooks
    class TransactionReconciler
      def initialize(qb_division = Division.root)
        @qb_division = qb_division
        @qb_connection = qb_division.qb_connection
        @principal_account = qb_division.principal_account
      end

      # Creates or updates a transaction in QB based on a Transaction object created in Madeline.
      def reconcile(transaction)
        je = builder.build_for_qb(transaction)

        # If the transaction already has a qb_id then it already exists in QB, so we should update it.
        if transaction.qb_id.present?
          journal_entry = service.update(je)
        else
          journal_entry = service.create(je)
        end

        journal_entry
      end

      private

      attr_reader :qb_connection, :principal_account, :qb_division

      def builder
        @builder ||= TransactionBuilder.new(qb_division)
      end

      def service
        @service ||= ::Quickbooks::Service::JournalEntry.new(qb_connection.auth_details)
      end
    end
  end
end
