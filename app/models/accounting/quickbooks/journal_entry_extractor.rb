module Accounting
  module Quickbooks
    class JournalEntryExtractor < TransactionExtractor

      attr_accessor :line_items
      def set_type
        puts "set type in journal entry ext"
        int_rcv_acct = loan.qb_division.interest_receivable_account
        int_inc_acct = loan.qb_division.interest_income_account
        prin_acct = loan.qb_division.principal_account

        @line_items = txn.line_items
        num_li = line_items.size
        puts "#{num_li} line items"
        if num_li > 3
          txn.loan_transaction_type_value = :other
        elsif num_li == 2 && line_items_include_debit_to_account(int_rcv_acct) && line_items_include_credit_to_account(int_inc_acct)
          txn.loan_transaction_type_value = :interest
        elsif num_li == 2 && line_items_contain_at_least_one('Credit') && line_items_include_debit_to_account(prin_acct)
          txn.loan_transaction_type_value = :disbursement
        elsif num_li == 3 && line_items_contain_at_least_one('Debit') && line_items_include_credit_to_account(prin_acct)
          txn.loan_transaction_type_value = :repayment
        else
          txn.loan_transaction_type_value = :other
        end
      end

      def set_managed
        puts "doc number: #{doc_number}"
        puts "type: #{txn.loan_transaction_type_value}"
        if ['disbursement', 'repayment'].include?(txn.loan_transaction_type_value) && doc_number && doc_number.include?('MS-Managed')
          txn.managed = true
        elsif txn.loan_transaction_type_value == 'interest' && doc_number && doc_number.include?('MS-Automatic')
          txn.managed = true
        else
          txn.managed = false
        end
      end

      private

      def line_item_by_account_id(account_id)
        index = line_items.find_index{|li| li.account.id == account_id}
        index.present? ? line_items[index] : nil
      end

      def line_items_include_debit_to_account(account)
        li = line_item_by_account_id(account.id)
        puts "debit li: #{li}"
        li && li.debit?
      end

      def line_items_include_credit_to_account(account)
        li = line_item_by_account_id(account.id)
        puts "credit li: #{li}"
        li && li.credit?
      end

      def line_items_contain_at_least_one(posting_type)
        !line_items.select{ |li| li.posting_type == posting_type }.empty?
      end

      def doc_number
        txn.quickbooks_data['doc_number']
      end
    end
  end
end
