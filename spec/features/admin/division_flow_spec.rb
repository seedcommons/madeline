require 'rails_helper'

feature 'division flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_admin_access, :with_password, division: division).user }

  before do
    login_as(user, scope: :user)
  end

  scenario 'should work', js: true do
    visit(admin_divisions_path)
    expect(page).to have_content(division.name)

    within('#divisions') do
      click_link(division.id)
    end

    expect(page).to have_content(division.name)

    find('.edit-action').click

    fill_in('division[name]', with: 'Changed Name')

    click_button 'Update Division'
    expect(page).to have_content('Changed Name')
    expect(page).to have_content('Record was successfully updated.')
  end
end
