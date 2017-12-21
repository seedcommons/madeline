require 'rails_helper'

feature 'transaction flow', :accounting do
  # TODO: This should all not be dependent on using the root division. It should work in any Division.
  # Right now, the TransactionPolicy requires admin privileges on Division.root, and Accounts are
  # not scoped to division.
  let(:division) { Division.root }
  let!(:loan) { create(:loan, division: division) }
  let(:user) { create_admin(division) }
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

    describe 'transaction listing' do
      scenario 'with qb error during Updater' do
        Rails.configuration.x.test.raise_qb_error_during_updater = 'qb fail on index'
        visit "/admin/loans/#{loan.id}/transactions"
        expect(page).to have_alert('Some data may be out of date. (Error: qb fail on index)')
      end
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
        expect(page).to have_content("Interest Accrual for Loan ##{loan.id}")
      end

      scenario 'with validation error' do
        visit "/admin/loans/#{loan.id}/transactions"
        fill_txn_form(omit_amount: true)
        page.find('a[data-action="submit"]').click
        expect(page).to have_content("Amount can't be blank")
      end

      scenario 'with qb error during Updater' do
        # This process should not create any transactions (disbursement OR interest)
        # because it errors out.
        expect do
          visit "/admin/loans/#{loan.id}/transactions"
          fill_txn_form
          Rails.configuration.x.test.raise_qb_error_during_updater = 'qb fail on create'
          page.find('a[data-action="submit"]').click
          expect(page).to have_alert('Some data may be out of date. (Error: qb fail on create)',
            container: '.transaction-form')
        end.to change { Accounting::Transaction.count }.by(0)
      end
    end
  end

  describe 'show', js: true do
    let!(:txn) do
      create(:accounting_transaction,
        project_id: loan.id, description: 'I love icecream', division: division)
    end

    scenario 'can show transactions' do
      visit admin_loan_tab_path(loan, tab: 'transactions')
      click_on txn.txn_date.strftime('%B %-d, %Y')
      expect(page).to have_content('icecream')
    end
  end

  def fill_txn_form(omit_amount: false)
    click_on 'Add Transaction'
    select 'Disbursement', from: 'Type of Transaction'
    fill_in 'Date', with: Date.today.to_s
    fill_in 'Amount', with: '12.34' unless omit_amount
    select accounts.sample.name, from: 'Bank Account'
    fill_in 'Description', with: 'Palm trees'
    fill_in 'Memo', with: 'Chunky monkey'
  end
end
