module Accounting
  module Quickbooks
    class JournalEntryExtractor < TransactionExtractor

      attr_accessor :line_items
      delegate :qb_division, to: :loan

      def set_type
        txn.loan_transaction_type_value = txn_type
      end

      def set_managed
        txn.managed = ms_managed || ms_automatic
      end

      def extract_account
        txn.account = account
      end

      private

      def account
        case txn.loan_transaction_type_value
        when 'repayment'
          txn.line_items.select{|li| li.debit?}.first.account
        when 'disbursement'
          txn.line_items.select{|li| li.credit?}.first.account
        else
          nil
        end
      end

      def txn_type
        @line_items = txn.line_items
        num_li = line_items.size
        return :other if num_li > 3
        int_rcv_acct = qb_division.interest_receivable_account
        int_inc_acct = qb_division.interest_income_account
        prin_acct = qb_division.principal_account

        if num_li == 2 && line_items_include_debit_to_acct(int_rcv_acct) && line_items_include_credit_to_acct(int_inc_acct)
          :interest
        elsif num_li == 2 && line_items_contain_at_least_one('Credit') && line_items_include_debit_to_acct(prin_acct)
          :disbursement
        elsif num_li == 3 && line_items_contain_at_least_one('Debit') && line_items_include_credit_to_acct(prin_acct)
          :repayment
        else
          :other
        end
      end

      def line_item_by_account_id(account_id)
        index = line_items.find_index {|li| li.account.id == account_id}
        index.present? ? line_items[index] : nil
      end

      def line_items_include_debit_to_acct(account)
        li = line_item_by_account_id(account.id)
        li && li.debit?
      end

      def line_items_include_credit_to_acct(account)
        li = line_item_by_account_id(account.id)
        li && li.credit?
      end

      def line_items_contain_at_least_one(posting_type)
        !line_items.select { |li| li.posting_type == posting_type }.empty?
      end

      def doc_number
        txn.quickbooks_data['doc_number']
      end

      def ms_managed
        doc_number.present? && doc_number.include?('MS-Managed')
      end

      def ms_automatic
        doc_number.present? && doc_number.include?('MS-Automatic')
      end
    end
  end
end
