module Accounting
  module QB
    class TransactionExtractor
      attr_reader :txn, :loan

      def initialize(txn)
        @txn = txn
        @loan = txn.project
      end

      def extract!
        extract_additional_metadata
        remove_unmatched_madeline_lis
        extract_line_items
        set_type
        extract_account
        set_managed
        extract_customer
        set_deltas
        calculate_amount
        add_implicit_line_items
      end

      def extract_additional_metadata
        txn.sync_token = txn.quickbooks_data['sync_token']
      end

      def remove_unmatched_madeline_lis
        # If we have more line items than are in Quickbooks, we delete the extras.
        if txn.quickbooks_data['line_items'].count < txn.line_items.count
          mad_line_item_ids_to_destroy = []
          qb_ids = txn.quickbooks_data['line_items'].map { |h| h['id'].to_i }
          # chose not use where.not(qb_line_id: qb_ids).destroy all out of an abundance of caution
          # any errors in this code can be hard to detect and cause incorrect calculations
          txn.line_items.each do |li|
            mad_line_item_ids_to_destroy << li.id unless qb_ids.include?(li.qb_line_id)
          end
          mad_line_item_ids_to_destroy.each do |mad_id|
            txn.line_items.destroy(Accounting::LineItem.find(mad_id))
          end
        end
      end

      def set_deltas
        txn.calculate_deltas
      end

      def extract_line_items
        txn.quickbooks_data['line_items'].each do |li|
          begin
            acct = Accounting::Account.find_by(qb_id: li[qb_li_detail_key]['account_ref']['value'])
          rescue
            ::Accounting::ProblemLoanTransaction.create(loan: @loan, accounting_transaction: txn, message: :unprocessable_account, level: :error, custom_data: {})
          end
          # skip if line item does not have an account in Madeline
          next unless acct
          posting_type = li[qb_li_detail_key]['posting_type']
          posting_type ||= existing_li_posting_type unless posting_type.present?
          txn.line_item_with_id(li['id'].to_i).assign_attributes(
            account: acct,
            amount: li['amount'],
            posting_type: posting_type,
            description: li['description']
          )
        end
        txn.txn_date = txn.quickbooks_data['txn_date']
        txn.private_note = txn.quickbooks_data['private_note']
        txn.total = txn.quickbooks_data['total']
        txn.currency = lookup_currency
      end

      def set_type
        txn.loan_transaction_type_value = :other
      end

      def extract_account
        # do nothing in TransactionExtract
        # can be overridden in subclasses
      end

      def extract_customer
        # do nothing in TransactionExtract
        # can be overridden in subclasses
      end

      def set_managed
        txn.managed = false
      end

      def calculate_amount
        # This line may seem odd since the natural thing to do would be to simply compute the
        # amount based on the sum of the line items.
        # However, we define our 'amount' as the sum of the change_in_interest and change_in_principal,
        # which are computed from a special subset of line items (see the Transaction model for more detail).
        # This may mean that our amount may differ from the amount shown in Quickbooks for this transaction,
        # but that is ok because we do not push amount back to QB.
        txn.amount = (txn.change_in_interest + txn.change_in_principal).abs
      end

      def add_implicit_line_items
        # do nothing in TransactionExtract
        # can be overridden in subclasses
      end

      def qb_li_detail_key
        'journal_entry_line_detail'
      end

      private

      def lookup_currency
        if txn.quickbooks_data && txn.quickbooks_data[:currency_ref]
          Currency.find_by(code: quickbooks_data[:currency_ref][:value]).try(:id)
        elsif loan
          loan.currency
        end
      end

      def doc_number_includes(string)
        doc_number = txn.quickbooks_data['doc_number']
        doc_number.present? && doc_number.include?(string)
      end
    end
  end
end
