require 'rails_helper'

RSpec.describe Accounting::Quickbooks::FullFetcher, type: :model do
  subject { described_class.new(instance_double(Accounting::Quickbooks::Connection)) }
  let(:division) { create(:division, :with_accounts) }

  describe '#fetch_all' do
    it "removes and restores accounts" do
      accounts = division.accounts
      subject.fetch_all
      # expect(division.reload.accounts).to
      # Accounts should be restored with the same QB ids but they should have different DB ids
    end

    it "sets division account association to nil if account no longer exists after fetch"
  end
end
