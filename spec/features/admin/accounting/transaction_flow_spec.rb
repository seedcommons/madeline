require 'rails_helper'

feature 'transaction flow' do
  let(:user) { create_admin(root_division) }

  before do
    login_as(user, scope: :user)
  end

  describe 'all transactions' do
    let(:updater) { instance_double(Accounting::Quickbooks::Updater, last_updated_at: Time.zone.now) }
    let!(:transactions) { create_list(:accounting_transaction, 2) }

    before do
      allow(Accounting::Quickbooks::Updater).to receive(:new).and_return(updater)
    end

    scenario 'loads properly', js: true do
      # Should update transactions
      expect(updater).to receive(:update)

      visit '/admin/accounting/transactions'

      expect(page.text.gsub ',', '').to have_content(transactions[0].amount.to_s)
    end
  end

  describe 'transactions for loan' do
    let!(:loan) { create(:loan) }
    let!(:accounts) { create_list(:accounting_account, 2) }

    before do
      OptionSetCreator.new.create_loan_transaction_type
    end

    # This spec does not test TransactionCreator at all because stubbing out
    # all the necessary things was not practical at the time.
    # Eventually we should refactor the Quickbooks code such that stubbing is easier.
    scenario 'creates new transaction', js: true do
      visit "/admin/loans/#{loan.id}/transactions"
      click_on 'Add Transaction'
      select 'Disbursement', from: 'Type of Transaction'
      fill_in 'Date', with: Date.today.to_s
      select accounts.sample.name, from: 'Bank Account'
      fill_in 'Amount', with: '12.34'
      fill_in 'Description', with: 'Foo bar'
      fill_in 'Memo', with: 'Chunky monkey'
      click_on 'Add'

      expect(page).to have_content('Foo bar')
    end
  end

  describe 'show', js: true do
    let!(:loan) { create(:loan) }
    let!(:txn) { create(:accounting_transaction, project_id: loan.id, description: 'I love icecream') }

    scenario 'can show transactions' do
      visit admin_loan_tab_path(loan, tab: 'transactions')
      click_on txn.txn_date.strftime('%B %-d, %Y')
      sleep 5
      expect(page).to have_content('icecream')
    end
  end

end
