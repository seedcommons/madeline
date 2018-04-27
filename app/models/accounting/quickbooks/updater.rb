# Updater is reponsible for grabbing only the updates that have happened in Quickbooks
# since the last time this class was run. If no Quickbooks data exists in the sytem
# yet, FullFetcher will need to be run first.
# Updater also kicks off the recalculation process in InterestCalculator once it is done fetching.
module Accounting
  module Quickbooks

    class Updater
      attr_reader :qb_connection

      MIN_TIME_BETWEEN_UPDATES = 5.seconds

      def initialize(qb_connection = Division.root.qb_connection)
        @qb_connection = qb_connection
      end

      # Fetches all changes from Quickbooks since the last update.
      # Note that *all* changes are pulled from Quickbooks even if the `loan` parameter is given.
      # Fetched data is initially stored in the objects' qb_data attribute, but NOT copied into the
      # associated attributes.
      #
      # If the loan parameter is given, this method also extracts QB data for Transactions
      # related to ONLY the given loan. See extract_qb_data for more details.
      #
      # Raises a DataResetRequiredError if there are updates
      # too far in the past for the `since` method to access.
      #
      # This argument can either be a single loan or an array of loans
      def update(loans = nil)
        raise NotConnectedError unless qb_connection
        return if too_soon_to_run_again?

        changes.each do |type, qb_objects|
          qb_objects.each do |qb_object|
            if should_be_deleted?(qb_object)
              delete_qb_object(qb_object_type: type, qb_object: qb_object)
            else
              create_or_update(qb_object_type: type, qb_object: qb_object)
            end
          end
        end

        # We record last_updated_at as the time the update *finishes* because last_updated_at
        # is used to avoid runs that immediately follow each other as in the case of a transaction creation
        # followed by a transaction listing. If we record the time the update *started* and the update
        # takes some time, we would need to increase the MIN_TIME_BETWEEN_UPDATES value and that might
        # make it frustrating for users who want to deliberately re-run the updater.
        # The other function of last_updated_at is to check if a full sync needs to be run,
        # but that condition is measured in days, not seconds, so this small a difference shouldn't matter.
        qb_connection.update_attribute(:last_updated_at, Time.now)

        if loans
          # check if loan is one object or multiple
          loans = [loans] if loans.is_a? Loan

          loans.each do |loan|
            if loan.transactions.present?
              update_ledger(loan)
              InterestCalculator.new(loan).recalculate
            end
          end
        end
      end

      private

      def too_soon_to_run_again?
        return false if qb_connection.last_updated_at.nil?
        Time.now - qb_connection.last_updated_at < MIN_TIME_BETWEEN_UPDATES
      end

      def update_ledger(loan)
        prev_tx = nil
        loan.transactions.standard_order.each do |txn|
          extract_qb_data(txn)
          txn.reload.calculate_balances(prev_tx: prev_tx)
          txn.currency = lookup_currency(txn)
          txn.save!
          prev_tx = txn
        end
      end

      # Extracts data for a given Transaction from the JSON in `quickbooks_data`
      # into the Transaction's attributes and associated LineItems.
      # Creates/deletes LineItems as needed.
      def extract_qb_data(txn)
        return unless txn.quickbooks_data.present?

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

        # This line may seem odd since the natural thing to do would be to simply compute the
        # amount based on the sum of the line items.
        # However, we define our 'amount' as the sum of the change_in_interest and change_in_principal,
        # which are computed from a special subset of line items (see the Transaction model for more detail).
        # This may mean that our amount may differ from the amount shown in Quickbooks for this transaction,
        # but that is ok.
        txn.amount = (txn.change_in_interest + txn.change_in_principal).abs

        txn.save!
      end

      def lookup_currency(txn)
        project = txn.project

        if txn.quickbooks_data && txn.quickbooks_data[:currency_ref]
          Currency.find_by(code: quickbooks_data[:currency_ref][:value]).try(:id)
        elsif project
          project.currency
        end
      end

      def changes
        unless last_updated_at && last_updated_at > max_updated_at
          raise DataResetRequiredError
        end

        service.since(types, last_updated_at).all_types
      end

      def create_or_update(qb_object_type:, qb_object:)
        model = ar_model_for(qb_object_type)
        model.create_or_update_from_qb_object!(qb_object_type: qb_object_type, qb_object: qb_object)
      end

      def types
        Transaction::QB_OBJECT_TYPES + [Account::QB_OBJECT_TYPE]
      end

      def ar_model_for(qb_object_type)
        return Account if Account::QB_OBJECT_TYPE == qb_object_type
        Transaction
      end

      def delete_qb_object(qb_object_type:, qb_object:)
        model = ar_model_for(qb_object_type)
        model.where(qb_id: qb_object.id).destroy_all
      end

      def should_be_deleted?(qb_object)
        qb_object.try(:status) == 'Deleted'
      end

      def service
        ::Quickbooks::Service::ChangeDataCapture.new(qb_connection.auth_details)
      end

      def max_updated_at
        30.days.ago - 1.minute
      end

      def last_updated_at
        qb_connection.last_updated_at
      end
    end
  end
end
