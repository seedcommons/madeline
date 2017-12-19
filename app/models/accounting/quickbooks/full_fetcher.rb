# Does a full sync with Quickbooks for Accounts and Transactions. Creates new objects as needed, and
# updates existing objects.
module Accounting
  module Quickbooks
    class FullFetcher
      attr_reader :qb_connection

      def initialize(qb_connection = Division.root.qb_connection)
        @qb_connection = qb_connection
      end

      def fetch_all
        divisions_accounts = clear_all_accounts!

        ::Accounting::Transaction.destroy_all
        ::Accounting::Account.destroy_all

        started_fetch_at = Time.zone.now

        ::Accounting::Quickbooks::AccountFetcher.new(@qb_connection).fetch
        ::Accounting::Quickbooks::TransactionFetcher.new(@qb_connection).fetch

        qb_connection.update_attribute(:last_updated_at, started_fetch_at)

        restore_all_accounts!(divisions_accounts)
      end

      private

      # Set all divisions' accounts to nil and return a hash of the QB ids of the removed accounts
      # by division
      def clear_all_accounts!
        divisions_accounts = {}
        Division.all.each do |d|
          accounts_qb_ids = {
            principal_qb_id: d.principal_account&.qb_id,
            interest_receivable_qb_id: d.interest_receivable_account&.qb_id,
            interest_income_qb_id: d.interest_income_account&.qb_id,
          }
          d.update(
            principal_account_id: nil,
            interest_receivable_account_id: nil,
            interest_income_account_id: nil,
          )
          divisions_accounts[d.id] = accounts_qb_ids
        end
        divisions_accounts
      end

      # Restore all divisions' accounts to the ones passed in. Argument is expected to be a hash of
      # the form returned by `#clear_all_accounts!`. NOTE: If a previously selected account no
      # longer exists after the full sync from QB, it will be set to nil. This is by design.
      def restore_all_accounts!(divisions_accounts)
        divisions_accounts.each do |did, qb_ids|
          Division.find(did).update(
            principal_account: Accounting::Account.find_by(qb_id: qb_ids[:principal_qb_id]),
            interest_receivable_account: Accounting::Account.find_by(qb_id: qb_ids[:interest_receivable_qb_id]),
            interest_income_account: Accounting::Account.find_by(qb_id: qb_ids[:interest_income_qb_id]),
          )
        end
      end

    end
  end
end
