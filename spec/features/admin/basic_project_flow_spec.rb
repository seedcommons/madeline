require 'rails_helper'

feature 'basic project flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_member_access, :with_password, division: division).user }
  let!(:basic_project) { create(:basic_project, division: division) }

  before do
    login_as(user, scope: :user)
  end

  scenario 'should work', js: true do
    visit(admin_basic_projects_path)
    expect(page).to have_content(basic_project.name)
  end
end
