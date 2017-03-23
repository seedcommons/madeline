require 'rails_helper'

feature 'transaction flow' do
  let(:user) { create_admin(root_division) }
  let!(:transactions) { create_list(:accounting_transaction, 2) }

  before do
    login_as(user, scope: :user)
    allow(Accounting::Quickbooks::FetcherBase).to receive(:new).and_return(double(fetch: nil))
  end

  scenario 'loads properly', js: true do
    visit "/admin/accounting/transactions"
    expect(page).to have_content(transactions[0].qb_transaction_type)
  end
end
