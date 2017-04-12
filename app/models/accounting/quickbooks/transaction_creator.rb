module Accounting
  module Quickbooks
    class TransactionCreator
      attr_reader :qb_connection

      def initialize(qb_connection = Division.root.qb_connection)
        @qb_connection = qb_connection
      end

      def add_disbursement(amount:, loan_id:, memo:, qb_bank_account_id:, qb_customer_id:)
        je = ::Quickbooks::Model::JournalEntry.new
        je.private_note = memo

        je.line_items << create_line_item(
          amount: amount,
          loan_id: loan_id,
          posting_type: 'Debit',
          qb_account_id: Division.root.interest_receivable_account.qb_id,
          qb_customer_id: qb_customer_id
        )

        je.line_items << create_line_item(
          amount: amount,
          loan_id: loan_id,
          posting_type: 'Credit',
          qb_account_id: qb_bank_account_id,
          qb_customer_id: qb_customer_id
        )

        service = ::Quickbooks::Service::JournalEntry.new(qb_connection.auth_details)

        service.create(je)
      end

      private

      def create_line_item(amount:, loan_id:, posting_type:, qb_account_id:, qb_customer_id:)
        line_item = ::Quickbooks::Model::Line.new
        line_item.detail_type = 'JournalEntryLineDetail'
        jel = ::Quickbooks::Model::JournalEntryLineDetail.new
        line_item.journal_entry_line_detail = jel

        jel.entity = create_customer(qb_customer_id: qb_customer_id)

        # The QBO api needs a fully persisted class before we can associate it.
        # We need to either find or create the class, and use the returned Id.
        jel.class_id = find_or_create_qb_class(loan_id: loan_id).id

        line_item.amount = amount
        jel.posting_type = posting_type
        jel.account_id = qb_account_id

        line_item
      end

      def create_customer(qb_customer_id:)
        entity = ::Quickbooks::Model::Entity.new
        entity.type = 'Customer'
        entity_ref = ::Quickbooks::Model::BaseReference.new(qb_customer_id)
        entity.entity_ref = entity_ref

        entity
      end

      def find_or_create_qb_class(loan_id:)
        service = ::Quickbooks::Service::Class.new(qb_connection.auth_details)

        loan_ref = service.find_by(:name, loan_id).first
        return loan_ref if loan_ref

        qb_class = ::Quickbooks::Model::Class.new
        qb_class.name = loan_id

        service.create(qb_class)
      end
    end
  end
end
