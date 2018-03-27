module Accounting
  module Quickbooks
    class DataExtractor
      attr_reader :txn, :loan

      def initialize(txn)
        @txn = txn
        @loan = txn.project
      end

      def extract!
        # if 'other', managed: false
        # If we have more line items than are in Quickbooks, we delete the extras.
        if txn.quickbooks_data['line_items'].count < txn.line_items.count
          qb_ids = txn.quickbooks_data['line_items'].map { |h| h['id'].to_i }

          txn.line_items.each do |li|
            txn.line_items.destroy(li) unless qb_ids.include?(li.qb_line_id)
          end
        end

        txn.quickbooks_data['line_items'].each do |li|
          acct = Account.find_by(qb_id: li['journal_entry_line_detail']['account_ref']['value'])

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

        # set transaction type
        txn.loan_transaction_type_value = txn_type

        # This line may seem odd since the natural thing to do would be to simply compute the
        # amount based on the sum of the line items.
        # However, we define our 'amount' as the sum of the change_in_interest and change_in_principal,
        # which are computed from a special subset of line items (see the Transaction model for more detail).
        # This may mean that our amount may differ from the amount shown in Quickbooks for this transaction,
        # but that is ok.
        txn.amount = (txn.change_in_interest + txn.change_in_principal).abs

        txn.save!
      end

      private

      def lookup_currency
        if txn.quickbooks_data && txn.quickbooks_data[:currency_ref]
          Currency.find_by(code: quickbooks_data[:currency_ref][:value]).try(:id)
        elsif loan
          loan.currency
        end
      end

      def txn_type
        line_items = txn.quickbooks_data['line_items']
        li_details = {}

        line_items.each do |li|
          line_item = txn.line_item_with_id(li['id'].to_i)
          li_details[line_item.posting_type] = line_item.account
        end

        if (li_details['Debit'] && li_details['Debit'].id == loan.division.interest_receivable_account.id) &&
          (li_details['Credit'] && li_details['Credit'].id == loan.division.interest_income_account.id)
          return 'interest'

        # having issues comparing `txn.account`. it seems that it is not set
        # it sets the amount in the line item but not the transaction

        elsif (li_details['Debit'] && li_details['Debit'].id == loan.division.principal_account.id) &&
          (li_details['Credit'] && li_details['Credit'].id == txn.account.id)
          return 'disbursement'
        elsif ((li_details['Credit'] && li_details['Credit'].id == loan.division.principal_account.id) ||
          (li_details['Credit'] && li_details['Credit'].id == loan.division.interest_receivable_account.id)) &&
          (li_details['Debit'] && li_details['Debit'].id == txn.account.id)
          return 'repayment'
        else
          return 'other'
        end
      end
    end
  end
end
