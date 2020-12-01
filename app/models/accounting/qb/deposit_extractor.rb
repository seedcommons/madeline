# frozen_string_literal: true

module Accounting
  module QB
    # Extract Deposit format quickbook transactions
    class DepositExtractor < TransactionExtractor
      attr_accessor :line_items
      delegate :qb_division, to: :loan

      def extract_line_items
        Rails::Debug.logger.ap("existing line items:")
        Rails::Debug.logger.ap(txn.line_items)
        Rails::Debug.logger.ap("extracting qb line items . . . ")
        txn.quickbooks_data['line_items'].each do |li|
          begin
            acct = Accounting::Account.find_by(qb_id: li[qb_li_detail_key]['account_ref']['value'])
          rescue
            ::Accounting::ProblemLoanTransaction.create(loan: @loan, accounting_transaction: txn, message: :unprocessable_account, level: :error, custom_data: {})
          end
          # skip if line item does not have an account in Madeline
          next unless acct
          posting_type = li[qb_li_detail_key]['posting_type']
          Rails::Debug.logger.ap("posting type: #{posting_type}")
          txn.line_item_with_posting_type(posting_type).assign_attributes(
            account: acct,
            amount: li['amount'],
            description: li['description'],
            qb_id: li['id'].to_i
          )
        end
        txn.txn_date = txn.quickbooks_data['txn_date']
        txn.private_note = txn.quickbooks_data['private_note']
        txn.total = txn.quickbooks_data['total']
        txn.currency = lookup_currency
      end

      def set_type
        txn.loan_transaction_type_value = 'repayment'
      end

      def extract_account
        qb_id = txn.quickbooks_data["deposit_to_account_ref"]["value"]
        txn.account = Accounting::Account.find_by(qb_id: qb_id)
      end

      # Using total assumes that all line items in txn are for accts in Madeline.
      # This assumption is safe because we never push amount to QB.
      def calculate_amount
        txn.amount = txn.total
      end

      def add_implicit_line_items
        li = txn.line_item_with_posting_type("Debit")
        li.assign_attributes(
          account: txn.account,
          amount: txn.amount,
          posting_type: 'Debit'
        )
      end

      def existing_li_posting_type(madeline_li)
        # this used to always return "Credit"
        madeline_li.posting_type || "Credit"
      end

      def qb_li_detail_key
        'deposit_line_detail'
      end
    end
  end
end
