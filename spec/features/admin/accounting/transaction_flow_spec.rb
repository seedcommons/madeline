require 'rails_helper'

feature 'transaction flow' do
  let(:user) { create_admin(root_division) }
  let!(:transactions) { create_list(:accounting_transaction, 2) }
  let(:updater) { instance_double(Accounting::Quickbooks::Updater, last_updated_at: Time.zone.now) }

  before do
    login_as(user, scope: :user)
    allow(Accounting::Quickbooks::FetcherBase).to receive(:new).and_return(double(fetch: nil))
    allow(Accounting::Quickbooks::Updater).to receive(:new).and_return(updater)
  end

  scenario 'loads properly' do
    # Should update transactions
    expect(updater).to receive(:update)

    visit "/admin/accounting/transactions"
    expect(page).to have_content(transactions[0].qb_transaction_type)
  end
end
