require 'rails_helper'

feature 'transaction flow' do
  let!(:loan) { create(:loan, division: Division.root) }
  let(:user) { create_admin(Division.root) }
  let!(:txn) { create(:accounting_transaction, project: loan) }

  before do
    Division.root.update_attributes!(
      principal_account: create(:account),
      interest_income_account: create(:account),
      interest_receivable_account: create(:account)
    )
    login_as(user, scope: :user)
  end

  context 'transactions for loan', js: true do
    let(:acct_1) { create(:accounting_account) }
    let(:acct_2) { create(:accounting_account) }
    let!(:accounts) { [acct_1, acct_2] }

    before do
      OptionSetCreator.new.create_loan_transaction_type
    end

    describe 'new transaction' do
      # This spec does not test TransactionBuilder at all because stubbing out
      # all the necessary things was not practical at the time.
      # Eventually we should refactor the Quickbooks code such that stubbing is easier.
      scenario 'creates new transaction' do
        visit "/admin/loans/#{loan.id}/transactions"
        fill_txn_form
        page.find('a[data-action="submit"]').click
        expect(page).to have_content('Palm trees')
      end
    end

    describe 'error handling' do
      before do

      end

      scenario 'error thrown on index page load is displayed' do
        Rails.configuration.x.test.set_invalid_model_error = 'qb model error'
        visit "/admin/loans/#{loan.id}/transactions"
        expect(page).to have_alert('Some data may be out of date. (Error: qb model error)')
      end

      scenario 'throws error in txn creation modal' do
        visit "/admin/loans/#{loan.id}/transactions"
        fill_txn_form
        Rails.configuration.x.test.set_invalid_model_error = 'qb model error'
        page.find('a[data-action="submit"]').click
        expect(page).to have_alert('Some data may be out of date. (Error: qb model error)')
      end
    end
  end

  describe 'show', js: true do
    let!(:txn) { create(:accounting_transaction, project_id: loan.id, description: 'I love icecream') }

    scenario 'can show transactions' do
      visit admin_loan_tab_path(loan, tab: 'transactions')
      click_on txn.txn_date.strftime('%B %-d, %Y')
      expect(page).to have_content('icecream')
    end
  end

  def fill_txn_form
    click_on 'Add Transaction'
    select 'Disbursement', from: 'Type of Transaction'
    fill_in 'Date', with: Date.today.to_s
    select accounts.sample.name, from: 'Bank Account'
    fill_in 'Amount', with: '12.34'
    fill_in 'Description', with: 'Palm trees'
    fill_in 'Memo', with: 'Chunky monkey'
  end
end
