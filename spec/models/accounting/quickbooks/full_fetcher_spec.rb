require 'rails_helper'

RSpec.describe Accounting::Quickbooks::FullFetcher, type: :model do
  let(:qb_connection) { create(:accounting_quickbooks_connection) }
  subject { described_class.new(qb_connection) }
  let(:division) { create(:division, :with_accounts) }
  Division.root.update!(qb_connection: qb_connection)

  describe '#fetch_all' do
    it "removes and restores accounts" do
      # account_fetcher = instance_double(Accounting::Quickbooks::AccountFetcher)
      # transaction_fetcher = instance_double(Accounting::Quickbooks::TransactionFetcher)
      # expect(account_fetcher).to receive(:new)
      # expect(transaction_fetcher).to receive(:new)
      accounts = division.accounts
      subject.fetch_all
      # expect(division.reload.accounts).to
      # Accounts should be restored with the same QB ids but they should have different DB ids
    end

    it "sets division account association to nil if account no longer exists after fetch"
  end
end
