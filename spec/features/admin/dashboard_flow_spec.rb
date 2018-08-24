require 'rails_helper'

feature 'dashboard flow' do
  before do
    @division = create(:division)
    @user = create_member(@division)
    @person = Person.find(@user.profile_id)
    @loan1 = create(:loan, division: @division)
    @loan2 = create(:loan, division: @division)

    login_as(@user, scope: :user)
  end

  describe "assigned steps" do
    scenario "section exists on page" do
      visit admin_dashboard_path
      expect(page).to have_content('Project Steps Assigned to Me')
    end

    scenario "show assigned steps" do
      step1 = create(:project_step, agent: @person, project: @loan1, scheduled_start_date: Date.today - 2.years)
      step2 = create(:project_step, agent: @person, project: @loan2, scheduled_start_date: Date.today - 1.month)
      step3 = create(:project_step, agent: @person, project: @loan2, scheduled_start_date: Date.today + 2.weeks)
      step4 = create(:project_step, agent: @person, project: @loan1, scheduled_start_date: Date.today + 6.months)
    end
  end
end
