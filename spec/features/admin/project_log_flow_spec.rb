require 'rails_helper'

feature 'loan flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_member_access, :with_password, division: division).user }
  let!(:project_log) { create(:project_log, division: division) }

  before do
    login_as(user, scope: :user)
  end

  scenario 'should work', js: true do
    visit(admin_project_logs_path)
    expect(page).to have_content(project_log.summary) # summary not rendered
    # puts project_log.summary
    # puts project_log.details
  end
end
