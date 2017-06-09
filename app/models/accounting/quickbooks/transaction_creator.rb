module Accounting
  module Quickbooks

    # Responsible for creating transaction entries in quickbooks.
    class TransactionCreator
      attr_reader :qb_connection, :principal_account

      def initialize(root_division = Division.root)
        @qb_connection = root_division.qb_connection
        @principal_account = root_division.principal_account
      end

      def add_disbursement(transaction)
        je = ::Quickbooks::Model::JournalEntry.new
        je.private_note = transaction.private_note
        je.txn_date = transaction.txn_date if transaction.txn_date.present?

        qb_customer_ref = customer_reference(transaction.project.organization)
        qb_department_ref = department_reference(transaction.project)

        je.line_items << create_line_item(
          amount: transaction.amount,
          loan_id: transaction.project_id,
          posting_type: 'Debit',
          description: transaction.description,
          qb_account_id: principal_account.qb_id,
          qb_customer_ref: qb_customer_ref,
          qb_department_ref: qb_department_ref
        )

        je.line_items << create_line_item(
          amount: transaction.amount,
          loan_id: transaction.project_id,
          posting_type: 'Credit',
          description: transaction.description,
          qb_account_id: transaction.account.qb_id,
          qb_customer_ref: qb_customer_ref,
          qb_department_ref: qb_department_ref
        )

        service.create(je)
      end

      private

      def customer_reference(organization)
        Customer.new(organization: organization, qb_connection: qb_connection).reference
      end

      def department_reference(loan)
        Department.new(division: loan.division, qb_connection: qb_connection).reference
      end

      def service
        @service ||= ::Quickbooks::Service::JournalEntry.new(qb_connection.auth_details)
      end

      def class_service
        @class_service ||= ::Quickbooks::Service::Class.new(qb_connection.auth_details)
      end

      def create_line_item(amount:, loan_id:, posting_type:, description:, qb_account_id:, qb_customer_ref:, qb_department_ref:)
        line_item = ::Quickbooks::Model::Line.new
        line_item.detail_type = 'JournalEntryLineDetail'
        jel = ::Quickbooks::Model::JournalEntryLineDetail.new
        line_item.journal_entry_line_detail = jel

        jel.entity = qb_customer_ref
        jel.department_ref = qb_department_ref

        # The QBO api needs a fully persisted class before we can associate it.
        # We need to either find or create the class, and use the returned Id.
        jel.class_id = find_or_create_qb_class(loan_id: loan_id).id

        line_item.amount = amount
        line_item.description = description
        jel.posting_type = posting_type
        jel.account_id = qb_account_id

        line_item
      end

      def find_or_create_qb_class(loan_id:)
        loan_ref = class_service.find_by(:name, loan_id).first
        return loan_ref if loan_ref

        qb_class = ::Quickbooks::Model::Class.new
        qb_class.name = loan_id

        class_service.create(qb_class)
      end
    end
  end
end
