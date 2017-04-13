module Accounting
  module Quickbooks
    class TransactionCreator
      attr_reader :qb_connection, :interest_receivable_account

      def initialize(root_division = Division.root)
        @qb_connection = root_division.qb_connection
        @interest_receivable_account = root_division.interest_receivable_account
      end

      def add_disbursement(amount:, loan_id:, memo:, qb_bank_account_id:, qb_customer_id:)
        je = ::Quickbooks::Model::JournalEntry.new
        je.private_note = memo

        je.line_items << create_line_item(
          amount: amount,
          loan_id: loan_id,
          posting_type: 'Debit',
          qb_account_id: interest_receivable_account.qb_id,
          qb_customer_id: qb_customer_id
        )

        je.line_items << create_line_item(
          amount: amount,
          loan_id: loan_id,
          posting_type: 'Credit',
          qb_account_id: qb_bank_account_id,
          qb_customer_id: qb_customer_id
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

      def create_line_item(amount:, loan_id:, posting_type:, qb_account_id:, qb_customer_id:)
        line_item = ::Quickbooks::Model::Line.new
        line_item.detail_type = 'JournalEntryLineDetail'
        jel = ::Quickbooks::Model::JournalEntryLineDetail.new
        line_item.journal_entry_line_detail = jel

        jel.entity = create_customer_reference(qb_customer_id: qb_customer_id)

        # The QBO api needs a fully persisted class before we can associate it.
        # We need to either find or create the class, and use the returned Id.
        jel.class_id = find_or_create_qb_class(loan_id: loan_id).id

        line_item.amount = amount
        jel.posting_type = posting_type
        jel.account_id = qb_account_id

        line_item
      end

      # We are not creating a customer here, but a customer reference.
      # The gem does not implement a helper method for _id like account or class.
      def create_customer_reference(qb_customer_id:)
        entity = ::Quickbooks::Model::Entity.new
        entity.type = 'Customer'
        entity_ref = ::Quickbooks::Model::BaseReference.new(qb_customer_id)
        entity.entity_ref = entity_ref

        entity
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
