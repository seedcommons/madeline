require "rails_helper"

feature "settings flow", :accounting do
  let(:division) { Division.root }
  let(:user) { create_admin(division) }

  before do
    login_as(user, scope: :user)
  end

  describe "authentication" do
    context "no qb connection" do
      # only case in accounting where division should not have accts or qb_connection at start of spec
      before do
        division.qb_connection.delete
      end

      scenario do
        visit "/admin/accounting/settings"
        expect(page).to have_content "Not Connected"
        click_on "Click To Connect"
        expect(page).to have_content "Connected to "
        expect(page).to have_content "QuickBooks data import pending"
      end
    end
  end

  describe "initial page load and authentication" do
    context "qb connection exists but qb grant invalid" do
      before do
        division.qb_connection.update!(invalid_grant: true)
      end
      scenario do
        visit "/admin/accounting/settings"
        expect(page).to have_content "Not Connected"
        click_on "Click To Connect"
        expect(page).to have_content "Connected to "
        expect(page).to have_content "QuickBooks data import pending"
      end
    end

    context "qb connection exists and qb grant is valid" do
      scenario do
        visit "/admin/accounting/settings"
        expect(page).to have_content "Connected to "
      end
    end
  end

  describe "setting details" do
    let!(:accounts) { create_list(:account, 4) }
    let(:prin_acct_name) { accounts.first.name }
    let(:int_rcv_acct_name) { accounts[1].name }
    let(:int_inc_acct_name) { accounts[2].name }

    context "last full fetch of QB data was successful" do
      before do
        Task.create(
          job_type_value: :full_fetcher,
          activity_message_value: "x",
          job_class: "FullFetcherJob",
          job_first_started_at: Time.current - 15.minutes,
          job_succeeded_at: Time.current - 3.minutes
        )
      end

      scenario do
        visit "/admin/accounting/settings"
        select prin_acct_name, from: "division[principal_account_id]"
        select int_rcv_acct_name, from: "division[interest_receivable_account_id]"
        select int_inc_acct_name, from: "division[interest_income_account_id]"
        cbd = Time.zone.today.to_s
        fill_in "Closed Books Date", with: Time.zone.today.to_s
        check "division[qb_read_only]"
        click_on "Save"
        expect(page).to have_content "Connected to "
        expect(page).to have_content "QuickBooks data import succeeded."
        expect(page).to have_select("division[principal_account_id]", selected: prin_acct_name)
        expect(page).to have_select("division[interest_receivable_account_id]", selected: int_rcv_acct_name)
        expect(page).to have_select("division[interest_income_account_id]", selected: int_inc_acct_name)
        expect(page).to have_field("Closed Books Date", with: cbd)
        expect(page).to have_checked_field("division[qb_read_only]")
      end
    end

    context "connected but qb full fetch is pending" do
      before do
        Task.create(job_type_value: :full_fetcher, activity_message_value: "x", job_class: "FullFetcherJob")
      end

      scenario do
        visit "/admin/accounting/settings"
        expect(page).to have_content("QuickBooks data import pending.")
      end
    end
  end

  describe "disconnect" do
    scenario do
      visit "/admin/accounting/settings"
      click_on "Disconnect"
      visit "/admin/accounting/settings"
      expect(page).to have_content "Not Connected"
    end
  end
end
