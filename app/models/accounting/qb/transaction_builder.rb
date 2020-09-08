# TransactionBuilder is responsible for building Quickbooks JournalEntry objects from Madeline Transactions.
# Note that these JournalEntrys may or may not already exist in Quickbooks. This is because we
# need a fully initialized JournalEntry object to perform both creates AND updates via the Quickbooks API.
# This class is NOT responsible for running the actual create/update operation via the API.
#
# However, it may initiate API calls while getting references for customer (QB equivalent for Organization),
# department (QB equivalent for Division), and class (QB equivalent for Loan) if corresponding
# objects don't exist yet in Quickbooks.
module Accounting
  module QB
    class TransactionBuilder
      attr_reader :qb_division, :qb_connection, :principal_account

      def initialize(qb_division = Division.root)
        @qb_division = qb_division
        @qb_connection = qb_division.qb_connection
        @principal_account = qb_division.principal_account
      end

      def build_for_qb(transaction)
        if transaction.is_a_check?
          build_check_for_qb(transaction)
        else
          build_je_for_qb(transaction)
        end
      end

      # Creates a Purchase of type check for QB based on disbursement txn object in Madeline.
      # A check in QB has one line item whereas a disbursement txn has two LIs in Madeline.
      def build_check_for_qb(transaction)
        p = ::Quickbooks::Model::Purchase.new

        # If transaction already exists in QB, these are required
        if transaction.qb_id
          p.id = transaction.qb_id
          p.sync_token = transaction.quickbooks_data['sync_token']
        else
          p.doc_number = set_journal_number(transaction)
        end

        p.private_note = transaction.private_note
        p.txn_date = transaction.txn_date if transaction.txn_date.present?
        # p.account_ref = transaction.account.try(:reference)
        # p.account_id = 1987 # stub w expense account id; transaction.account.qb_id
        p.department_ref = department_reference(transaction.project)
        p.payment_type = "Check"
        p.entity_ref = transaction.vendor.try(:reference) # all check txns have a vendor
        p.total = transaction.amount

        qb_customer_ref = customer_reference(transaction)
        qb_class_id = find_or_create_qb_class(loan_id: transaction.project_id).id

        # no posting type on AccountBasedExpenseLineItems in QB
        p.line_items << build_check_line_item(
          id: nil,
          amount: transaction.amount,
          description: transaction.description,
          qb_customer_ref: qb_customer_ref,
          qb_class_id: qb_class_id
        )
        p
      end

      def build_check_line_item(id:, amount:, description:, qb_customer_ref:, qb_class_id:)
        line_item = ::Quickbooks::Model::PurchaseLineItem.new
        line_item.detail_type = 'AccountBasedExpenseLineDetail'
        line_item.id = id
        detail = ::Quickbooks::Model::AccountBasedExpenseLineDetail.new
        # detail.account_ref = @principal_account.reference
        # detail.account_id = 1797 # stub w expense account id;@principal_account.qb_id # always prin account
        detail.class_id = qb_class_id # ref in documentation
        detail.customer_ref = qb_customer_ref # not sure if this still makes sense on a check?
        detail.billable_status = "NotBillable"
        line_item.account_based_expense_line_detail = detail
        line_item.amount = amount
        line_item.description = description
        line_item
      end

      # Creates a transaction for Quickbooks based on a Transaction object created in Madeline. Line
      # items in QB mirror line items in Madeline.
      def build_je_for_qb(transaction)
        je = ::Quickbooks::Model::JournalEntry.new

        # If transaction already exists in QB, these are required
        if transaction.qb_id
          je.id = transaction.qb_id
          je.sync_token = transaction.quickbooks_data['sync_token']
        else
          je.doc_number = set_journal_number(transaction)
        end

        je.private_note = transaction.private_note
        je.txn_date = transaction.txn_date if transaction.txn_date.present?

        qb_customer_ref = customer_reference(transaction)
        qb_department_ref = department_reference(transaction.project)

        # We use the journal entry class field to store the loan ID.
        # The loan ID is actually stored as the 'name' of the class object in Quickbooks.
        # Note that 'class' in Quickbooks has nothing to do with a class in Ruby. It's just a
        # bit of metadata about the journal entry.
        # The QBO api needs a fully persisted class before we can associate it.
        # We need to either find or create the class, and use the returned Id.
        qb_class_id = find_or_create_qb_class(loan_id: transaction.project_id).id

        transaction.line_items.each_with_index do |li, i|
          je.line_items << build_je_line_item(
            id: i,
            amount: li.amount,
            posting_type: li.posting_type,
            description: transaction.description,
            qb_account_id: li.account.qb_id,
            qb_customer_ref: qb_customer_ref,
            qb_department_ref: qb_department_ref,
            qb_class_id: qb_class_id
          )
        end

        je
      end

      private

      def customer_reference(transaction)
        ensure_accounting_customer_set(transaction)
        transaction.customer.reference
      end

      def department_reference(loan)
        if loan.qb_department.present?
          Department.reference(loan.qb_department)
        else
          # Users are also blocked by UI from to creating a txn without a dept
          raise StandardError, I18n.t('quickbooks.department_not_set')
        end
      end

      def service
        @service ||= ::Quickbooks::Service::JournalEntry.new(qb_connection.auth_details)
      end

      def class_service
        @class_service ||= ::Quickbooks::Service::Class.new(qb_connection.auth_details)
      end

      # Builds a Quickbooks `Line` object, which represents a Quickbooks line item, not to be confused
      # with a Madeline LineItem.
      def build_je_line_item(id:, amount:, posting_type:, description:, qb_account_id:,
        qb_customer_ref:, qb_department_ref:, qb_class_id:)
        line_item = ::Quickbooks::Model::Line.new
        line_item.detail_type = 'JournalEntryLineDetail'
        line_item.id = id
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
        loan_ref = class_service.find_by(:name, "Loan ID #{loan_id}").first
        return loan_ref if loan_ref

        qb_class = ::Quickbooks::Model::Class.new
        qb_class.name = "Loan ID #{loan_id}"
        # QB api requires the parent class id to be an integer even tho elsewhere it is treated as str
        qb_class.parent_ref = ::Quickbooks::Model::BaseReference.new(qb_division.qb_parent_class_id.to_i)
        class_service.create(qb_class)
      end

      # a transaction does not need a customer unless/until it is built for quickbooks
      # a txn can be created multiple ways (e.g. by user, interest calculator, qb import)
      # and at various points the customer is not available to set anyway
      # so we do this ensure step here in the one place it's needed and where the last
      # fallback options that involve retrieving or creating a customer via quickbooks is doable.
      def ensure_accounting_customer_set(transaction)
        return if transaction.customer.present?
        customer = transaction.project.default_accounting_customer_for_transaction(transaction) || CustomerBuilder.new(qb_division).new_accounting_customer_for(transaction.project.organization)
        transaction.update(customer: customer)
      end

      def set_journal_number(txn)
        return nil if txn.loan_transaction_type_value == 'other'
        txn.loan_transaction_type_value == 'interest' ? 'MS-Automatic' : 'MS-Managed'
      end
    end
  end
end
