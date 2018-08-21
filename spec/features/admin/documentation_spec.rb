require 'rails_helper'

feature 'documentation' do
  let(:user) { create_admin(create(:division)) }

  scenario 'creation' do
    visit new_documentation_path(caller: 'loans#new', html_identifier: 'food')

    expect(page).to have_field('HTML Identifier', with: 'food')
  end
end
