require 'rails_helper'

feature 'transaction flow', :accounting do
  # TODO: This should all not be dependent on using the root division. It should work in any Division.
  # Right now, the TransactionPolicy requires admin privileges on Division.root, and Accounts are
  # not scoped to division.
  let(:division) { Division.root }
  let!(:qb_dept) { create(:department, name: "Test QB Department", division: division) }
  let!(:loan) { create(:loan, :active, division: division) }
  let(:user) { create_admin(division) }
  let!(:customers) { create_list(:customer, 3) }

  before do
    Division.root.update_attributes!(
      principal_account: create(:account),
      interest_income_account: create(:account),
      interest_receivable_account: create(:account),
      qb_read_only: false
    )
    login_as(user, scope: :user)
  end

  context 'transactions for loan', js: true do
    let(:acct_1) { create(:accounting_account) }
    let(:acct_2) { create(:accounting_account) }
    let!(:accounts) { [acct_1, acct_2] }
    let!(:vendors) { create_list(:vendor, 2) }

    before do
      OptionSetCreator.new.create_loan_transaction_type
    end

    # TODO: Figure out whether this makes sense as a test case anymore
    xdescribe 'transaction listing' do
      scenario 'with qb error during Updater' do
        Rails.configuration.x.test.raise_qb_error_during_updater = 'qb fail on index'
        visit "/admin/loans/#{loan.id}/transactions"
        expect(page).to have_alert('Some data may be out of date. (Error: qb fail on index)')
      end
    end

    context "loan's transactions are read-only" do
      let!(:loan) { create(:loan, txn_handling_mode: Loan::TXN_MODE_READ_ONLY, division: division) }
      scenario 'create new transaction button is hidden' do
        visit "/admin/loans/#{loan.id}/transactions"
        expect(page).to have_content('Transactions are read-only')
        # expect "Add Transaction" to not be available
        expect(page).not_to have_selector('.btn[data-action="new-transaction"]')
      end
    end

    context "loan's qb_division has qb_read-only on" do
      before do
        Division.root.update_attribute(:qb_read_only, true)
      end
      scenario 'create new transaction button is hidden' do
        visit "/admin/loans/#{loan.id}/transactions"
        # expect "Add Transaction" to not be available
        expect(page).not_to have_selector('.btn[data-action="new-transaction"]')
      end
    end

    context "loan is not active" do
      let!(:loan) { create(:loan, :completed, division: division) }
      scenario 'create new transaction button is hidden' do
        visit "/admin/loans/#{loan.id}/transactions"
        expect(page).to have_content('Transactions are read-only')
        # expect "Add Transaction" to not be available
        expect(page).not_to have_selector('.btn[data-action="new-transaction"]')
      end
    end

    context "loan's division has no qb department set'" do
      before { division.update(qb_department: nil) }
      let!(:loan) { create(:loan, :active, division: division) }
      scenario 'warning is visible and Create Transactions button hidden' do
        visit "/admin/loans/#{loan.id}/transactions"
        expect(page).to have_content("Please set the QB division on this loan's Madeline division in order to create transactions.")
        # expect "Add Transaction" to be available
        expect(page).not_to have_selector('.btn[data-action="new-transaction"]')
      end
    end

    describe 'new transaction' do
      # This spec does not test TransactionBuilder, InterestCalculator, Updater, or other QB classes
      # because stubbing out all the necessary things was not practical at the time.
      # Eventually we should refactor the Quickbooks code such that stubbing is easier.
      scenario 'creates new transaction' do
        visit "/admin/loans/#{loan.id}/transactions"
        fill_txn_form
        expect(page).to have_content('Test QB Department')
        page.find('a[data-action="submit"]').click
        expect(page).to have_content('Palm trees')
      end

      scenario 'disbursement and check fields' do
        visit "/admin/loans/#{loan.id}/transactions"
        click_on 'Add Transaction'
        expect(page).not_to have_content('Disbursement Type')
        expect(page).not_to have_content('Vendor')
        expect(page).not_to have_content('Check Number')
        choose 'Disbursement'
        expect(page).to have_content('Disbursement Type')
        expect(page).to have_content('Vendor')
        expect(page).not_to have_content('Check Number')
        choose 'Check'
        expect(page).to have_content('Disbursement Type')
        expect(page).to have_content('Check Number')
        fill_in 'Check Number', with: 123
        select vendors.sample.name, from: 'Vendor'
        fill_in 'Date', with: Time.zone.today.to_s
        fill_in 'accounting_transaction[amount]', with: '12.34'
        select accounts.sample.name, from: 'Bank Account'
        select customers.sample.name, from: 'QuickBooks Customer'
        fill_in 'Description', with: 'Test check'
        fill_in 'Memo', with: 'Chunky monkey'
        page.find('a[data-action="submit"]').click
        expect(page).to have_content('Test check')
      end

      scenario 'with validation error' do
        visit "/admin/loans/#{loan.id}/transactions"
        fill_txn_form(omit_amount: true)
        page.find('a[data-action="submit"]').click
        expect(page).to have_content("Amount #{loan.currency.code} can't be blank")
      end

      context 'closed books date set' do
        before do
          division.update(closed_books_date: Time.zone.today - 1. month)
        end

        scenario 'date before closed books date' do
          visit "/admin/loans/#{loan.id}/transactions"
          fill_txn_form(date: Time.zone.today - 1.year)
          page.find('a[data-action="submit"]').click
          expect(page).to have_content("Date must be after the Closed Books Date")
        end

        scenario 'date after closed books date' do
          visit "/admin/loans/#{loan.id}/transactions"
          fill_txn_form(date: Time.zone.today)
          page.find('a[data-action="submit"]').click
          expect(page).to have_content("Palm trees")
        end

        after do
          division.update(closed_books_date: nil)
        end
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

  def fill_txn_form(omit_amount: false, date: Time.zone.today)
    click_on 'Add Transaction'
    choose 'Disbursement'
    fill_in 'Date', with: date.to_s
    fill_in 'accounting_transaction[amount]', with: '12.34' unless omit_amount
    select accounts.sample.name, from: 'Bank Account'
    select customers.sample.name, from: 'QuickBooks Customer'
    fill_in 'Description', with: 'Palm trees'
    fill_in 'Memo', with: 'Chunky monkey'
  end
end
