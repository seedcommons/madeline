require "rails_helper"

# just tests that admins and members can access a statement assuming transactions
# are there, and the statement only contains txns from the previous year.

# does not text any underlying txn/ledger logic, specific headers, or that the print button works.

describe "loan statement flow", :accounting do
  let(:division) { Division.root }
  let!(:qb_dept) { create(:department, name: "Test QB Department", division: division) }
  let!(:loan) { create(:loan, :active, division: division) }
  let(:user) { create_admin(division) }
  let!(:customers) { create_list(:customer, 3) }

  before do
    Division.root.update!(
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


    describe "generate last year's statement" do
      context "when transactions present" do
        let!(:transactions_too_old) { create_list(:accounting_transaction, 3,
          project: loan,
          description: "old",
          txn_date: Time.zone.now.last_year.beginning_of_year - 1.day,
        )}
        let!(:transactions_to_include) { create_list(:accounting_transaction, 3,
          project: loan,
          description: "test transaction",
          txn_date: Time.zone.now.last_year.beginning_of_year + 3.days,
        )}
        let!(:transactions_too_recent) { create_list(:accounting_transaction, 3,
          project: loan,
          description: "too recent",
          txn_date: Time.zone.now.last_year.end_of_year + 30.days,
        )}

        context "as admin" do
          let(:user) { create_admin(division) }
          before do
            division.root.update(closed_books_date: Time.zone.now.last_year.end_of_year)
          end

          scenario "able to access statement" do
            visit "/admin/loans/#{loan.id}/transactions"
            click_on "Print"
            new_window = window_opened_by { click_link "Statement for Last Year" }
            within_window new_window do
              expect(page).to have_content("Print")

              expect(page).to have_content(division.name)
              expect(page).to have_content("test transaction")

              # exclude txns outside last year
              expect(page).not_to have_content("old")
              expect(page).not_to have_content("too recent")
            end
          end
        end

        context "as member" do
          before do
            division.root.update(closed_books_date: Time.zone.now.last_year.end_of_year)
          end
          let(:user) { create_member(division) }

          scenario "able to access statement" do
            visit "/admin/loans/#{loan.id}/transactions"
            click_on "Print"
            new_window = window_opened_by { click_link "Statement for Last Year" }
            within_window new_window do
              expect(page).to have_content("Print")
            end
          end
        end

        context "end date is after closed books date" do
          before do
            division.root.update(closed_books_date:Time.zone.now.last_year.beginning_of_year)
          end
          scenario "shows draft warning" do
            visit "/admin/loans/#{loan.id}/transactions"
            click_on "Print"
            new_window = window_opened_by { click_link "Statement for Last Year" }
            within_window new_window do
              expect(page).to have_content("DRAFT")
            end
          end
        end

        context "end date is before closed books date" do
          before do
            division.root.update(closed_books_date: Time.zone.now.last_year.end_of_year)
          end
          scenario "hides draft warning" do
            visit "/admin/loans/#{loan.id}/transactions"
            click_on "Print"
            new_window = window_opened_by { click_link "Statement for Last Year" }
            within_window new_window do
              expect(page).not_to have_content("DRAFT")
            end
          end
        end
      end
    end
  end
end
