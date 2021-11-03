require "rails_helper"

describe "project log flow", js: true do
  let(:division) { create(:division, notify_on_new_logs: true) }
  let(:user) { create_admin(division) }
  let(:loan) { create(:loan, division: division) }
  let!(:step) { create(:project_step, project: loan, parent: loan.root_timeline_entry) }

  before do
    login_as(user, scope: :user)
    ActiveJob::Base.queue_adapter = :test
  end

  scenario "create" do
    visit("/admin/loans/#{loan.id}/timeline")
    find(".step-menu-col .fa-cog").click
    click_on("Add Log")

    # Wait for modal to load
    expect(page).to have_content("New Log")
    check("Step completed on this date")
    fill_in("project_log_summary_en", with: "Stuff")

    # Wait for fill-in to complete (test was flaking out without this.)
    expect(page).to have_field("project_log_summary_en", with: "Stuff")

    # Save the log and wait for the request to complete before checking for the Job
    expect do
      find(".btn-primary", text: "Save Log").click
      expect(page).to have_css(".recent-logs", text: "Stuff")
    end.to have_enqueued_job(LogNotificationJob)
  end
end
