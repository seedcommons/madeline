require 'rails_helper'

feature 'dashboard flow' do
  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let(:person) { Person.find(user.profile_id) }
  let(:loan) { create(:loan, division: division) }
  let(:loan2) { create(:loan, division: create(:division)) }

  before { login_as(user, scope: :user) }

  describe "assigned steps" do
    scenario "section exists on page" do
      visit admin_dashboard_path
      expect(page).to have_content('Project Steps Assigned to Me')
    end

    scenario "show no assigned steps" do
      visit admin_dashboard_path
      expect(page).to have_content('There are no project steps assigned to you.')
    end

    scenario "show assigned steps", js: true do
      step1 = create(:project_step, agent: person, project: loan, scheduled_start_date: Date.today - 2.years, is_finalized: true, actual_end_date: nil)
      step2 = create(:project_step, agent: person, project: loan2, scheduled_start_date: Date.today - 1.month, is_finalized: true, actual_end_date: nil)
      step3 = create(:project_step, agent: person, project: loan, scheduled_start_date: Date.today + 2.weeks, is_finalized: true, actual_end_date: nil)
      step4 = create(:project_step, agent: person, project: loan, scheduled_start_date: Date.today + 6.months, is_finalized: true, actual_end_date: nil)



      visit admin_dashboard_path
      # Change to specific division, and ensure the page reloads properly
      select_division(division.name)

      # visit admin_dashboard_path

      expect(page).not_to have_content(step2.summary)
      expect(page).to have_content(step3.summary)

      expect(page).not_to have_content(step1.summary)
      expect(page).not_to have_content(step4.summary)
    end
  end
end
