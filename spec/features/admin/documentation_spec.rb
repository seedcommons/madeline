require 'rails_helper'

feature 'documentation' do
  let(:user) { create_admin(create(:division)) }

  before { login_as user }

  scenario 'creation' do
    visit new_admin_documentation_path(caller: 'loans#new', html_identifier: 'food')

    # fields are pre-filled correctly
    expect(page).to have_field('HTML Identifier', with: 'food')
    expect(page).to have_field('Calling Controller', with: 'loans')
    expect(page).to have_field('Calling Action', with: 'new')

    # add content
    fill_in 'Summary Content', with: 'This is my sample summary content'
    fill_in 'Page Content', with: 'This is my sample page content'

    click_on 'Save'

    # after saving, the contents are saved correctly
    visit admin_documentation_path(Documentation.last)
    expect(page).to have_field('Summary Content', with: 'This is my sample summary content')
    expect(page).to have_field('Page Content', with: 'This is my sample page content')
  end
end
