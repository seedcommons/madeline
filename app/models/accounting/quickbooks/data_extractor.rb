module Accounting
  module Quickbooks
    class DataExtractor
      attr_reader :txn

      def initialize(txn)
        @txn = txn
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
        project = txn.project

        if txn.quickbooks_data && txn.quickbooks_data[:currency_ref]
          Currency.find_by(code: quickbooks_data[:currency_ref][:value]).try(:id)
        elsif project
          project.currency
        end
      end
    end
  end
end
