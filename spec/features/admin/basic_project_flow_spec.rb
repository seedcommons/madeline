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

    within('#basic_projects') do
      click_link(basic_project.id)
    end

    expect(page).to have_content(basic_project.name)

    find('.edit-action').click

    fill_in('basic_project[name]', with: 'Changed Name')

    click_button 'Update Basic project'
    expect(page).to have_content('Changed Name')
    expect(page).to have_content('Record was successfully updated.')
  end
end
