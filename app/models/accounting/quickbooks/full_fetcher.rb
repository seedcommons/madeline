# Does a full reset with Quickbooks for Accounts and Transactions. Creates new objects as needed, and
# updates existing objects.
module Accounting
  module Quickbooks
    class FullFetcher
      attr_reader :qb_connection, :division

      def initialize(division)
        @division = division
        @qb_connection = division.qb_connection
      end

      def fetch_all
        accounts = clear_accounts!

        ::Accounting::LineItem.delete_all
        ::Accounting::Transaction.delete_all
        ::Accounting::Account.delete_all

        started_fetch_at = Time.zone.now

        ::Accounting::Quickbooks::AccountFetcher.new(division).fetch
        ::Accounting::Quickbooks::TransactionFetcher.new(division).fetch

        qb_connection.update_attribute(:last_updated_at, started_fetch_at)

        restore_accounts!(accounts)
      end

      private

      # Set this division's accounts to nil and return a hash of the QB ids of the removed accounts
      def clear_accounts!
        accounts_qb_ids = {
          principal: division.principal_account&.qb_id,
          interest_receivable: division.interest_receivable_account&.qb_id,
          interest_income: division.interest_income_account&.qb_id,
        }
        division.update(
          principal_account_id: nil,
          interest_receivable_account_id: nil,
          interest_income_account_id: nil,
        )
        accounts_qb_ids
      end

      # Restore all divisions' accounts to the ones passed in. Argument is expected to be a hash of
      # the form returned by `#clear_accounts!`. NOTE: If a previously selected account no longer
      # exists after the full sync from QB, it will be set to nil. This is by design.
      def restore_accounts!(accounts_qb_ids)
        division.update(
          principal_account:
            Accounting::Account.find_by(qb_id: accounts_qb_ids[:principal]),
          interest_receivable_account:
            Accounting::Account.find_by(qb_id: accounts_qb_ids[:interest_receivable]),
          interest_income_account:
            Accounting::Account.find_by(qb_id: accounts_qb_ids[:interest_income]),
        )
      end

    end
  end
end
