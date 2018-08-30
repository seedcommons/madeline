require 'rails_helper'

feature 'documentation' do
  let(:user) { create_admin(create(:division)) }
  let!(:doc) { create(:documentation, html_identifier: 'movies', summary_content: 'original summary content',
    page_title: 'original page title', page_content: 'original page content', calling_controller: 'basic_projects',
    calling_action: 'show'
  ) }

  before { login_as user }

  scenario 'complete documentation flow', js: true do
    visit admin_dashboard_path

    popover_link = page.find(:css, "a#dashboard-dashboard-title-link")
    popover_link.click

    new_link = page.find(:css, "a#dashboard-dashboard-title-new-link")
    new_link.click

    expect(page).to have_content "New Documentation"
    fill_in_content
    click_on "Create Documentation"

    expect(page).to have_content "successfully created"

    visit admin_dashboard_path
    popover_link.click

    expect(page).to have_content 'my summary content'

    edit_link = page.find(:css, "a#dashboard-dashboard-title-edit-link")
    edit_link.click

    expect(page).to have_content "Edit documentation"
    fill_in 'Summary Content', with: "EDITED SUMMARY CONTENT"
    click_on "Update Documentation"

    expect(page).to have_content 'successfully updated'

    popover_link.click

    expect(page).to have_content "EDITED SUMMARY CONTENT"

    documentation_window = window_opened_by { click_link "Learn more »" }
    within_window documentation_window do
      expect(page).to have_content "my page title"
      expect(page).to have_content "my page content"
      expect(page).not_to have_content "EDITED SUMMARY CONTENT"
    end
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

    # redirects to the correct page
    expect(page).to have_content('New Loan')
  end

  scenario 'editing', js: true do
    visit edit_admin_documentation_path(doc)

    # page is on English locale on load
    expect(page).to have_css('select#documentation_locale_en')

    # translations work
    select 'Español', from: 'documentation_locale_en'
    expect(page).to have_css('select#documentation_locale_es')

    # testing content
    fill_in_content
    click_on 'Update Documentation'

    expect(doc.reload.summary_content.text).to eq('my summary content')
    expect(doc.reload.page_title.text).to eq('my page title')
    expect(doc.reload.page_content.text).to eq('my page content')

    # redirects to the correct page
    expect(page).to have_content('Edit Project')
  end

  scenario 'show' do
    visit admin_documentation_path(doc)

    expect(page).to have_content('original page title')
    expect(page).to have_content('original page content')
  end

  def fill_in_content
    fill_in 'Summary Content', with: 'my summary content'
    fill_in 'Page Title', with: 'my page title'
    fill_in 'Page Content', with: 'my page content'
  end
end
