require "rails_helper"

describe "project step flow", js: true do
  let(:division) { create(:division) }
  let(:actor) { create_admin(division) }
  let(:loan) { create(:loan, name: "Foo Project", division: division) }
  let!(:step) do
    create(:project_step, project: loan, parent: loan.root_timeline_entry, summary: "Goose",
                          is_finalized: true, scheduled_start_date: "2020-01-01", scheduled_duration_days: 3)
  end

  before do
    OptionSetCreator.new.create_step_type
    login_as(actor, scope: :user)
  end

  describe "create" do
    scenario do
      visit("/admin/loans/#{loan.id}/timeline")
      click_on("Add Step")
      fill_in("project_step_summary_en", with: "Turkey")

      # Select a preceeding step and date should turn to read only
      select("Goose", from: "Preceding Step")
      expect(page).to have_content(/Scheduled Start Date\s+Jan 4, 2020/)
      check("Finalized")

      # Demonstrate validation error handling
      fill_in("project_step_scheduled_duration_days", with: "0")
      click_on("Submit")
      expect(page).to have_content("cannot be less than 1")

      fill_in("project_step_scheduled_duration_days", with: "1")
      click_on("Submit")
      expect(page).not_to have_css("#project-step-modal")
      expect(page).to have_content("Turkey")
    end
  end

  describe "update" do
    scenario do
      visit("/admin/loans/#{loan.id}/timeline")

      # Test dropdown instead of just using the main show link.
      all(".dropdown .fa-cog")[0].click
      find(".dropdown li", text: "Show").click

      # Demonstrate show view in modal
      expect(page).to have_content(/Finalized\s+Yes/)
      find(".edit-action").click

      # Cancel edit
      expect(page).to have_field("project_step_scheduled_duration_days")
      find("a", text: "Cancel Edit").click
      expect(page).not_to have_field("project_step_scheduled_duration_days")
      expect(page).to have_content(/Project\s+Foo Project/)

      # Demonstrate persistence of changes
      find(".edit-action").click
      fill_in("project_step_summary_en", with: "Chicken")
      click_on("Submit")
      expect(page).not_to have_css("#project-step-modal")
      expect(page).to have_content("Chicken")
    end
  end

  describe "destroy" do
    scenario do
      visit("/admin/loans/#{loan.id}/timeline")
      all(".dropdown .fa-cog")[0].click
      accept_confirm { find(".dropdown li", text: "Delete").click }
      expect(page).not_to have_content("Goose")
    end
  end

  describe "try to unfinalize too late" do
    let!(:step) do
      create(:project_step, project: loan, parent: loan.root_timeline_entry, summary: "Goose",
                            is_finalized: true, finalized_at: Time.current - 2.days)
    end

    scenario "hides finalize checkbox" do
      visit("/admin/loans/#{loan.id}/timeline")
      find("td", text: "Goose").click
      expect(page).to have_content(/Finalized\s+Yes \(Locked\)/)
      find(".edit-action").click
      expect(page).to have_field("project_step_scheduled_duration_days")
      expect(page).to have_content(/Finalized\s+Yes \(Locked\)/) # Still text, not editable
    end
  end

  describe "change date of finalized step" do
    before do
      OptionSetCreator.new.create_progress_metric
    end

    scenario "shows log modal and persists log successfully" do
      visit("/admin/loans/#{loan.id}/timeline")
      find("td", text: "Goose").click
      expect(page).to have_content(/Finalized\s+Yes/)
      find(".edit-action").click
      find("#project_step_scheduled_start_date").click
      expect(page).to have_css(".datepicker-days")
      find("td.day", text: "19").click
      click_on("Submit")

      # Log modal should appear
      expect(page).to have_content("The original date for this step will be remembered")
      select("Behind", from: "Status")
      find("#project_log_summary_en").set("Stuff", wait: 80)
      find("a.btn", text: "Add Log").click

      # Check log persisted
      find("td", text: "Goose").click
      find("a", text: "Show Logs").click
      expect(page).to have_content("Stuff")
    end
  end
end
