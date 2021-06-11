require "rails_helper"

feature "transaction flow", :accounting do
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

  context "transactions for loan", js: true do
    let(:acct_one) { create(:accounting_account) }
    let(:acct_two) { create(:accounting_account) }
    let!(:accounts) { [acct_one, acct_two] }
    let!(:vendors) { create_list(:vendor, 2) }

    before do
      OptionSetCreator.new.create_loan_transaction_type
    end

    describe "list transactions" do
      context "when transactions present" do
        let!(:transactions) { create_list(:accounting_transaction, 2, project: loan, description: "Pants") }
        let!(:unextracted_txn) do
          build(:accounting_transaction, :unextracted, project: loan, description: "Nonsense!").tap do |txn|
            txn.save(validate: false)
          end
        end

        context "when there are only irrelevant issues" do
          let!(:issue) { create(:accounting_sync_issue, level: :error, loan: create(:loan)) }

          scenario "shows transactions but not unextracted ones" do
            visit "/admin/loans/#{loan.id}/transactions"
            amt = ActiveSupport::NumberHelper.number_to_delimited(transactions[0].amount)
            expect(page).to have_content(amt)
            expect(page).to have_content("Pants")
            expect(page).not_to have_content("Nonsense!")
          end
        end

        context "when there are only warnings" do
          let!(:issue) { create(:accounting_sync_issue, level: :warning, loan: loan) }

          scenario "shows transactions and warning" do
            visit "/admin/loans/#{loan.id}/transactions"
            expect(page).to have_content("Pants")
            expect(page).to have_content("There is a sync warning for this loan")
          end
        end

        context "when there are errors" do
          let!(:issue) { create(:accounting_sync_issue, level: :error, loan: loan) }

          scenario "shows error and hides transactions" do
            visit "/admin/loans/#{loan.id}/transactions"
            expect(page).not_to have_content("Pants")
            expect(page).to have_content("There was a sync error for this loan")
          end
        end

        context "when transactions are writable" do
          scenario "create new transaction button is visible, no notice shown" do
            visit "/admin/loans/#{loan.id}/transactions"
            expect(page).not_to have_content("You can't add transactions")
            expect(page).to have_selector('.btn[data-action="new-transaction"]')
          end
        end

        context "when transactions are not writable" do
          let!(:loan) { create(:loan, :completed, division: division) }

          before do
            Division.root.update_attribute(:qb_read_only, true)
          end

          scenario "create new transaction button is hidden and reasons are shown" do
            visit "/admin/loans/#{loan.id}/transactions"
            expect(page).to have_content("You can't add transactions because: transactions are in read-only "\
              "mode for the division '#{loan.qb_division.name}' (see settings); "\
              "this loan is not active")
            expect(page).not_to have_selector('.btn[data-action="new-transaction"]')
          end
        end
      end

      context "when transactions not present but still writable" do
        scenario "shows no records notice and new txn button" do
          visit "/admin/loans/#{loan.id}/transactions"
          expect(page).to have_content("No records")
          expect(page).not_to have_content("You can't add transactions")
          expect(page).to have_selector('.btn[data-action="new-transaction"]')
        end
      end
    end

    describe "transaction order" do
      let!(:txn_attrs) {
        [{date: Date.parse("01-01-2020"), type: "disbursement", amt: 100},
         {date: Date.parse("01-01-2020"), type: "interest", amt: 0.01},
         {date: Date.parse("31-01-2020"), type: "interest", amt: 0.5},
         {date: Date.parse("15-02-2020"), type: "repayment", amt: 50},
         {date: Date.parse("15-02-2020"), type: "interest", amt: 0.2}]
      }
      let!(:txns) do
        txn_attrs.map do |attrs|
          create(:accounting_transaction,
                 txn_date: attrs[:date],
                 loan_transaction_type_value: attrs[:type],
                 amount: attrs[:amt],
                 project: loan)
        end
      end

      it "places interest txns before accompanying disbursement or repayment" do
        visit "/admin/loans/#{loan.id}/transactions"
        expect_ledger_row_column_to_contain(1, 1, "January 1, 2020")
        expect_ledger_row_column_to_contain(1, 2, "Interest")
        expect_ledger_row_column_to_contain(2, 1, "January 1, 2020")
        expect_ledger_row_column_to_contain(2, 2, "Disbursement")
        expect_ledger_row_column_to_contain(3, 1, "January 31, 2020")
        expect_ledger_row_column_to_contain(3, 2, "Interest")
        expect_ledger_row_column_to_contain(4, 1, "February 15, 2020")
        expect_ledger_row_column_to_contain(4, 2, "Interest")
        expect_ledger_row_column_to_contain(5, 1, "February 15, 2020")
        expect_ledger_row_column_to_contain(5, 2, "Repayment")
      end
    end

    describe "new transaction" do
      # This spec does not test TransactionBuilder, InterestCalculator, Updater, or other QB classes
      # because stubbing out all the necessary things was not practical at the time.
      # Eventually we should refactor the Quickbooks code such that stubbing is easier.
      scenario "creates new transaction" do
        visit "/admin/loans/#{loan.id}/transactions"
        fill_txn_form
        expect(page).to have_content("Test QB Department")
        page.find('a[data-action="submit"]').click
        expect(page).to have_content("Palm trees")
      end

      scenario "disbursement and check fields" do
        visit "/admin/loans/#{loan.id}/transactions"
        click_on "Add Transaction"
        expect(page).not_to have_content("Disbursement Type")
        expect(page).not_to have_content("Vendor")
        expect(page).not_to have_content("Check Number")
        choose "Disbursement"
        expect(page).to have_content("Disbursement Type")
        expect(page).to have_content("Vendor")
        expect(page).not_to have_content("Check Number")
        choose "Check"
        expect(page).to have_content("Disbursement Type")
        expect(page).to have_content("Check Number")
        fill_in "Check Number", with: 123
        select vendors.sample.name, from: "Vendor"
        fill_in "Date", with: Time.zone.today.to_s
        fill_in "accounting_transaction[amount]", with: "12.34"
        select accounts.sample.name, from: "Bank Account"
        select customers.sample.name, from: "Co-op (QBO)"
        fill_in "Description", with: "Test check"
        fill_in "Memo", with: "Chunky monkey"
        page.find('a[data-action="submit"]').click
        expect(page).to have_content("Test check")
      end

      scenario "with validation error" do
        visit "/admin/loans/#{loan.id}/transactions"
        fill_txn_form(omit_amount: true)
        page.find('a[data-action="submit"]').click
        expect(page).to have_content("Amount #{loan.currency.code} can't be blank")
      end

      context "closed books date set" do
        before do
          division.update(closed_books_date: Time.zone.today - 1.month)
        end

        scenario "date before closed books date" do
          visit "/admin/loans/#{loan.id}/transactions"
          fill_txn_form(date: Time.zone.today - 1.year)
          page.find('a[data-action="submit"]').click
          expect(page).to have_content("Date must be after the Closed Books Date")
        end

        scenario "date after closed books date" do
          visit "/admin/loans/#{loan.id}/transactions"
          fill_txn_form(date: Time.zone.today)
          page.find('a[data-action="submit"]').click
          expect(page).to have_content("Palm trees")
        end

        after do
          division.update(closed_books_date: nil)
        end
      end

      scenario "with qb error during Updater" do
        # This process should not create any transactions (disbursement OR interest)
        # because it errors out.
        expect do
          with_env("RAISE_QB_ERROR_DURING_UPDATER" => "1") do
            visit "/admin/loans/#{loan.id}/transactions"
            fill_txn_form
            page.find('a[data-action="submit"]').click
            expect(page).to have_alert("QuickBooks is temporarily unavailable",
                                       container: ".transaction-form")
          end
        end.to change { Accounting::Transaction.count }.by(0)
      end
    end

    describe "sync data" do
      scenario "successful" do
        visit "/admin/loans/#{loan.id}/transactions"
        click_on "Sync Data"
        expect(page).to have_alert("Loan successfully sync'd with QuickBooks")
      end

      scenario "with error" do
        with_env("RAISE_QB_ERROR_DURING_UPDATER" => "1") do
          visit "/admin/loans/#{loan.id}/transactions"
          click_on "Sync Data"
          expect(page).to have_alert("QuickBooks is temporarily unavailable")
        end
      end
    end
  end

  describe "show", js: true do
    let!(:txn) do
      create(:accounting_transaction,
             project_id: loan.id, description: "I love icecream", division: division)
    end

    scenario "can show transactions" do
      visit admin_loan_tab_path(loan, tab: "transactions")
      click_on txn.txn_date.strftime("%B %-d, %Y")
      expect(page).to have_content("icecream")
    end
  end

  def fill_txn_form(omit_amount: false, date: Time.zone.today)
    click_on "Add Transaction"
    choose "Repayment"
    fill_in "Date", with: date.to_s
    fill_in "accounting_transaction[amount]", with: "12.34" unless omit_amount
    select accounts.sample.name, from: "Bank Account"
    select customers.sample.name, from: "Co-op (QBO)"
    fill_in "Description", with: "Palm trees"
    fill_in "Memo", with: "Chunky monkey"
  end

  def expect_ledger_row_column_to_contain(row, column, content)
    within(:xpath, "//tbody/tr[#{row}]/td[#{column}]") do
      expect(page).to have_content(content)
    end
  end
end
