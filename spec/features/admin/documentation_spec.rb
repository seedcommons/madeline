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

    # translatable fields save appropriately
    fill_in 'Summary Content', with: 'my summary content'
    fill_in 'Page Title', with: 'my page title'
    fill_in 'Page Content', with: 'my page content'
    click_on 'Save'

    expect(Documentation.last.summary_content.text).to eq('my summary content')
    expect(Documentation.last.page_title.text).to eq('my page title')
    expect(Documentation.last.page_content.text).to eq('my page content')
  end
end
