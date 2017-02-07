require 'rails_helper'

feature 'organization flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_member_access, :with_password, division: division).user }
  let!(:org1) { create(:organization, division: division) }

  before do
    login_as(user, scope: :user)
  end

  scenario 'should work', js: true do
    visit(admin_organizations_path)
    expect(page).to have_content(org1.name)

    within('#organizations') do
      click_link(org1.id)
    end

    expect(page).to have_content(org1.name)

    find('.edit-action').click

    fill_in('organization[name]', with: 'Changed Name')

    click_button 'Update Organization'
    expect(page).to have_content('Changed Name')
    expect(page).to have_content('Record was successfully updated.')
  end
end
