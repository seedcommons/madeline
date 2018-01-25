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
      def update(loan = nil)
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

        if loan
          update_ledger(loan)
          InterestCalculator.new(loan).recalculate
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
        txn.amount = (txn.total_change).abs

        unless txn.project
          # The only line items we're interested in are those that have a class name in QB that
          # corresponds to a project id in Madeline
          relevant_line_items = []
          txn.quickbooks_data['line_items'].each do |li|
            class_name = li['journal_entry_line_detail']['class_ref']['name']
            if /^\d+$/.match class_name #&& Project.exists?(class_name.to_i)
              li['project_id'] = class_name.to_i
              li['qb_account_id'] = li['journal_entry_line_detail']['account_ref']['value']
              relevant_line_items << li
            end
          end

          # If txn has no project (usually because it's newly imported), set the project based on the
          # class name given in QB
          unless txn.project
            pids = relevant_line_items.map { |i| i['project_id'] }
            # Check that there's only one QB class name consisting only of digits, otherwise ignore txn
            return unless pids.uniq.count == 1
            # Only set if project found
            # Use find_by so as not to raise an error if not found
            txn.project = Project.find_by(id: pids.first.to_i)
          end

          unless txn.loan_transaction_type_value
            if txn.change_in_principal > 0
              txn.loan_transaction_type_value = 'disbursement'
            elsif txn.change_in_interest > 0
              txn.loan_transaction_type_value = 'interest'
            elsif txn.total_change < 0
              txn.loan_transaction_type_value = 'repayment'
            else
              return
            end
          end

          unless txn.account || txn.interest?
            qb_account_ids = relevant_line_items.map { |i| i['qb_account_id'] }
            non_special_account_ids = qb_account_ids.select do |i|
              !txn.qb_division.accounts.map(&:qb_id).include? i
            end
            return if non_special_account_ids.uniq.count == 1
            txn.account = Accounting::Account.find_by(qb_id: non_special_account_ids.first)
          end
        end

        txn.save!
      end

      private

      def too_soon_to_run_again?
        return false if qb_connection.last_updated_at.nil?
        Time.now - qb_connection.last_updated_at < MIN_TIME_BETWEEN_UPDATES
      end

      def update_ledger(loan)
        loan.transactions.standard_order.each do |txn|
          extract_qb_data(txn)
          txn.reload.calculate_balances
          txn.save!
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
