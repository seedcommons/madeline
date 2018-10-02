require 'rails_helper'

feature 'loan flow' do
  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let!(:loan) { create(:loan, division: division) }
  let(:parent_group) { create(:project_group) }
  let!(:child_group) { create(:project_group, project: loan, parent: parent_group) }

  before do
    login_as(user, scope: :user)
  end

  # This should work, but for some reason it fails a lot more often
  include_examples :flow do
    subject { loan }
  end

  describe "timeline" do
    let(:loan) { create(:loan, :with_timeline, division: division) }

    before do
      OptionSetCreator.new.create_step_type
    end

    xscenario "works", js: true do
      visit admin_loan_path(loan)
      click_on("Timeline")
      loan.timeline_entries.each do |te|
        expect(page).to have_content(te.summary) if te.is_a?(ProjectStep)
      end

      select("Finalized", from: "status")
      wait_for_loading_indicator

      loan.timeline_entries.each do |te|
        next unless te.is_a?(ProjectStep)
        if te.is_finalized?
          expect(page).to have_content(te.summary)
        else
          expect(page).not_to have_content(te.summary)
        end
      end

      # It's important to wait for the loading indicator after each of these select clicks.
      # Otherwise the requests may resolve in the wrong order and cause failures.
      select("All Statuses", from: "status")
      wait_for_loading_indicator

      select("Milestone", from: "type")
      wait_for_loading_indicator

      loan.timeline_entries.each do |te|
        next unless te.is_a?(ProjectStep)
        if te.milestone?
          expect(page).to have_content(te.summary)
        else
          expect(page).not_to have_content(te.summary)
        end
      end
    end
  end

  describe 'details' do
    scenario 'can duplicate', js: true do
      visit admin_loan_path(loan)

      accept_confirm { click_on('Duplicate') }
      expect(page).to have_content "Copy of #{loan.display_name}"
    end
  end

  scenario 'loan can not be created with the same person as pry and sec agent' do
    visit new_admin_loan_path
    select user.name, from: 'loan_primary_agent_id'
    select user.name, from: 'loan_secondary_agent_id'
    click_on 'Create Loan'
    expect(page).to have_content('The point person for this project cannot be the same as the second point person')
  end

  scenario 'loan with groups can be deleted' do
    visit admin_loan_path(loan)
    click_on 'Delete Loan'
    expect(page).to have_content('Record was successfully deleted')
  end
end
