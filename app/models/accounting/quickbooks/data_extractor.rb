module Accounting
  module Quickbooks
    class DataExtractor
      attr_reader :txn, :loan

      def initialize(txn)
        @txn = txn
        @loan = txn.project
      end

      def extract!
        # If we have more line items than are in Quickbooks, we delete the extras.
        if txn.quickbooks_data['line_items'].count < txn.line_items.count
          qb_ids = txn.quickbooks_data['line_items'].map { |h| h['id'].to_i }

          txn.line_items.each do |li|
            txn.line_items.destroy(li) unless qb_ids.include?(li.qb_line_id)
          end
        end

        txn.quickbooks_data['line_items'].each do |li|
          acct = Accounting::Account.find_by(qb_id: li['journal_entry_line_detail']['account_ref']['value'])

          # skip if line item does not have an account in Madeline
          next unless acct

          txn.line_item_with_id(li['id'].to_i).assign_attributes(
            account: acct,
            amount: li['amount'],
            posting_type: li['journal_entry_line_detail']['posting_type']
          )
        end

        txn.txn_date = txn.quickbooks_data['txn_date']
        txn.private_note = txn.quickbooks_data['private_note']
        txn.total = txn.quickbooks_data['total']

        txn.currency = lookup_currency

        # This line may seem odd since the natural thing to do would be to simply compute the
        # amount based on the sum of the line items.
        # However, we define our 'amount' as the sum of the change_in_interest and change_in_principal,
        # which are computed from a special subset of line items (see the Transaction model for more detail).
        # This may mean that our amount may differ from the amount shown in Quickbooks for this transaction,
        # but that is ok.
        txn.amount = (txn.change_in_interest + txn.change_in_principal).abs

        # set transaction type
        txn.loan_transaction_type_value = txn_type

        txn.managed = false if txn.loan_transaction_type_value == 'other'

        # TODO: set txn account
      end

      private

      delegate :qb_division, to: :loan

      def lookup_currency
        if txn.quickbooks_data && txn.quickbooks_data[:currency_ref]
          Currency.find_by(code: quickbooks_data[:currency_ref][:value]).try(:id)
        elsif loan
          loan.currency
        end
      end

      def txn_type
        line_items = txn.quickbooks_data['line_items']
        @int_rcv = qb_division.interest_receivable_account
        @int_inc = qb_division.interest_income_account
        @prin_acct = qb_division.principal_account

        li_accounts = {
          'Debit' => [],
          'Credit' => []
        }

        return 'other' if line_items.count > 3

        line_items.each do |li|
          line_item = txn.line_item_with_id(li['id'].to_i)
          li_accounts[line_item.posting_type] << line_item.account
        end

        set_type(li_accounts['Debit'], li_accounts['Credit'], line_items)
      end

      def set_type(debits, credits, lis)
        if lis.count == 2 && @int_rcv.in?(debits) && @int_inc.in?(credits)
          'interest'
        elsif lis.count == 2 && credits.any? && @prin_acct.in?(debits)
          return 'disbursement'
        elsif lis.count == 3 && debits.any? && @prin_acct.in?(credits) && @int_rcv.in?(credits)
          return 'repayment'
        else
          'other'
        end
      end
    end
  end
end
