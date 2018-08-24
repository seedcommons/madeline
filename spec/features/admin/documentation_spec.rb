require 'rails_helper'

feature 'documentation' do
  let(:user) { create_admin(create(:division)) }
  let!(:doc) { create(:documentation, html_identifier: 'movies') }

  before do
    login_as user
    doc.summary_content = 'original summary content'
    doc.page_title = 'original page title'
    doc.page_content = 'original page content'
    doc.save
  end

  scenario 'creation' do
    visit new_admin_documentation_path(caller: 'loans#new', html_identifier: 'food')

    # fields are pre-filled correctly
    expect(page).to have_field('HTML Identifier', with: 'food')
    expect(page).to have_field('Calling Controller', with: 'loans')
    expect(page).to have_field('Calling Action', with: 'new')

    # translatable fields save appropriately
    fill_in_content
    click_on 'Create Documentation'

    expect(Documentation.last.summary_content.text).to eq('my summary content')
    expect(Documentation.last.page_title.text).to eq('my page title')
    expect(Documentation.last.page_content.text).to eq('my page content')
  end

  scenario 'editing' do
    visit edit_admin_documentation_path(html_identifier: doc.html_identifier)

    fill_in_content
    click_on 'Update Documentation'

    expect(doc.reload.summary_content.text).to eq('my summary content')
    expect(doc.reload.page_title.text).to eq('my page title')
    expect(doc.reload.page_content.text).to eq('my page content')
  end

  def fill_in_content
    fill_in 'Summary Content', with: 'my summary content'
    fill_in 'Page Title', with: 'my page title'
    fill_in 'Page Content', with: 'my page content'
  end

  scenario 'show' do
    visit admin_documentation_path(doc.html_identifier)

    expect(page).to have_content('original page title')
    expect(page).to have_content('original page content')
  end
end
