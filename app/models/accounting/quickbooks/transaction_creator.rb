module Accounting
  module Quickbooks

    # Responsible for creating transaction entries in quickbooks.
    class TransactionCreator
      attr_reader :qb_connection, :principal_account

      def initialize(root_division = Division.root)
        @qb_connection = root_division.qb_connection
        @principal_account = root_division.principal_account
      end

      def add_disbursement(amount:, loan_id:, memo:, description:, qb_bank_account_id:, organization:, date: nil)
        je = ::Quickbooks::Model::JournalEntry.new
        je.private_note = memo
        je.txn_date = date if date.present?

        qb_customer_ref = create_customer_reference(organization: organization)

        je.line_items << create_line_item(
          amount: amount,
          loan_id: loan_id,
          posting_type: 'Debit',
          description: description,
          qb_account_id: principal_account.qb_id,
          qb_customer_ref: qb_customer_ref
        )

        je.line_items << create_line_item(
          amount: amount,
          loan_id: loan_id,
          posting_type: 'Credit',
          description: description,
          qb_account_id: qb_bank_account_id,
          qb_customer_ref: qb_customer_ref
        )

        service.create(je)
      end

      private

      def service
        @service ||= ::Quickbooks::Service::JournalEntry.new(qb_connection.auth_details)
      end

      def class_service
        @class_service ||= ::Quickbooks::Service::Class.new(qb_connection.auth_details)
      end

      def customer_service
        @customer_service ||= ::Quickbooks::Model::Customer.new(qb_connection.auth_details)
      end

      def create_line_item(amount:, loan_id:, posting_type:, description:, qb_account_id:, qb_customer_ref:)
        line_item = ::Quickbooks::Model::Line.new
        line_item.detail_type = 'JournalEntryLineDetail'
        jel = ::Quickbooks::Model::JournalEntryLineDetail.new
        line_item.journal_entry_line_detail = jel

        jel.entity = qb_customer_ref

        # The QBO api needs a fully persisted class before we can associate it.
        # We need to either find or create the class, and use the returned Id.
        jel.class_id = find_or_create_qb_class(loan_id: loan_id).id

        line_item.amount = amount
        line_item.description = description
        jel.posting_type = posting_type
        jel.account_id = qb_account_id

        line_item
      end

      # We are may be creating a customer here if needed. We return the qb_id and manualy create a reference.
      # The gem does not implement a helper method for _id like account or class.
      def create_customer_reference(organization:)
        qb_customer_id = find_or_create_qb_customer_id_from(organization: organization)

        entity = ::Quickbooks::Model::Entity.new
        entity.type = 'Customer'
        entity_ref = ::Quickbooks::Model::BaseReference.new(qb_customer_id)
        entity.entity_ref = entity_ref

        entity
      end

      def find_or_create_qb_customer_id_from(organization:)
        return organization.qb_id if organization.qb_id.present?

        qb_customer = ::Quickbooks::Model::Customer.new
        qb_customer.display_name = organization.name

        new_qb_customer = customer_service.create(qb_customer)

        new_qb_customer.id
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
