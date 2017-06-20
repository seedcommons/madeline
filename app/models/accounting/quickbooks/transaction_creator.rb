module Accounting
  module Quickbooks

    # Responsible for creating transaction entries in quickbooks.
    class TransactionCreator
      attr_reader :qb_connection, :principal_account

      def initialize(root_division = Division.root)
        @qb_connection = root_division.qb_connection
        @principal_account = root_division.principal_account
      end

      # Creates a disbursement transaction. Each such transaction consists of a journal entry
      # with two line items:
      # - a debit from the division's principal account
      # - a credit to the account specified in the transaction
      def add_disbursement(transaction)
        je = ::Quickbooks::Model::JournalEntry.new
        je.private_note = transaction.private_note
        je.txn_date = transaction.txn_date if transaction.txn_date.present?

        qb_customer_ref = customer_reference(transaction.project.organization)
        qb_department_ref = department_reference(transaction.project)

        # We use the journal entry class field to store the loan ID.
        # The loan ID is actually stored as the 'name' of the class object in Quickbooks.
        # Note that 'class' in Quickbooks has nothing to do with a class in Ruby. It's just a
        # bit of metadata about the journal entry.
        # The QBO api needs a fully persisted class before we can associate it.
        # We need to either find or create the class, and use the returned Id.
        qb_class_id = find_or_create_qb_class(loan_id: transaction.project_id).id

        je.line_items << create_line_item(
          amount: transaction.amount,
          posting_type: 'Debit',
          description: transaction.description,
          qb_account_id: principal_account.qb_id,
          qb_customer_ref: qb_customer_ref,
          qb_department_ref: qb_department_ref,
          qb_class_id: qb_class_id
        )

        je.line_items << create_line_item(
          amount: transaction.amount,
          posting_type: 'Credit',
          description: transaction.description,
          qb_account_id: transaction.account.qb_id,
          qb_customer_ref: qb_customer_ref,
          qb_department_ref: qb_department_ref,
          qb_class_id: qb_class_id
        )

        created_je = service.create(je)

        save_transaction(transaction, created_je)
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

      def save_transaction(transaction, qb_object)
        transaction.qb_transaction_type = 'JournalEntry'
        transaction.qb_id = qb_object.id
        transaction.quickbooks_data = qb_object.as_json
        transaction.save!
      end

      def create_line_item(amount:, posting_type:, description:, qb_account_id:,
        qb_customer_ref:, qb_department_ref:, qb_class_id:)
        line_item = ::Quickbooks::Model::Line.new
        line_item.detail_type = 'JournalEntryLineDetail'
        jel = ::Quickbooks::Model::JournalEntryLineDetail.new
        line_item.journal_entry_line_detail = jel

        jel.entity = qb_customer_ref
        jel.department_ref = qb_department_ref
        jel.class_id = qb_class_id

        line_item.amount = amount
        line_item.description = description
        jel.posting_type = posting_type
        jel.account_id = qb_account_id

        line_item
      end

      # We use the Quickbooks 'classes' to store the loan IDs.
      # This method finds or creates a QB class to hold a given loan ID.
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
