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
  end
end
