# frozen_string_literal: true

module Accounting
  module Quickbooks
    # Extract JournalEntry format quickbook transactions
    class JournalEntryExtractor < TransactionExtractor
      attr_accessor :line_items
      delegate :qb_division, to: :loan

      def set_type
        txn.loan_transaction_type_value = txn_type
      end

      def set_managed
        txn.managed = doc_number_includes('MS-Managed') || doc_number_includes('MS-Automatic')
      end

      def extract_account
        txn.account = account
      end

      private

      def account
        case txn.loan_transaction_type_value
        when 'repayment'
          txn.line_items.find(&:debit?).account
        when 'disbursement'
          txn.line_items.find(&:credit?).account
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

      def line_items_include_debit_to_acct(account)
        li = line_items.find { |i| i.account == account }
        li && li.debit?
      end

      def line_items_include_credit_to_acct(account)
        li = line_items.find { |i| i.account == account }
        li && li.credit?
      end

      def line_items_contain_at_least_one(posting_type)
        line_items.any? { |li| li.posting_type == posting_type }
      end

      def doc_number_includes(string)
        doc_number = txn.quickbooks_data['doc_number']
        doc_number.present? && doc_number.include?(string)
      end
    end
  end
end
