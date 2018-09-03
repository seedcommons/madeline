# TODO - refactor file
require 'rails_helper'

feature 'documentation', js: true do
  let(:division) { create(:division) }
  let(:user) { create_admin(division) }
  let(:project) {  create(:basic_project, division: division) }
  let(:loan) {  create(:loan, division: division) }
  let(:doc) { create(:documentation, html_identifier: 'movies', summary_content: 'original summary content',
    page_title: 'original page title', page_content: 'original page content') }

  before { login_as user }

  describe 'documentation creation flow' do
    scenario 'flow 1 on dashboard' do
      visit admin_dashboard_path

      popover_link = page.find(:css, "a#dashboard-dashboard-title-link")
      popover_link.click

      new_link = page.find(:css, "a#dashboard-dashboard-title-new-link")
      new_link.click

      expect(page).to have_content "New Documentation"

      # fields are pre-filled correctly
      expect(page).to have_field('HTML Identifier', with: 'dashboard-dashboard-title')
      expect(page).to have_field('Calling Controller', with: 'dashboard')
      expect(page).to have_field('Calling Action', with: 'dashboard')

      fill_in_content
      click_on "Create Documentation"

      documentation_created

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

    scenario 'flow 2 on loan form' do
      visit new_admin_loan_path

      popover_link = page.find(:css, "a#loans-new-title-link")
      popover_link.click

      new_link = page.find(:css, "a#loans-new-title-new-link")
      new_link.click

      expect(page).to have_content "New Documentation"

      # fields are pre-filled correctly
      expect(page).to have_field('HTML Identifier', with: 'loans-new-title')
      expect(page).to have_field('Calling Controller', with: 'loans')
      expect(page).to have_field('Calling Action', with: 'new')

      fill_in_content
      click_on "Create Documentation"

      documentation_created

      # redirects to the correct page
      expect(page).to have_content('New Loan')

      # to see saved documentation
      popover_link.click

      # page opens in another tab
      # this tests the url is right
      expect(find_link('Learn more »')[:target]).to eq('_blank')
      expect(find_link('Learn more »')[:href]).to include(admin_documentation_path(Documentation.last))

      # to edit documentation
      edit_link = page.find(:css, "a#loans-new-title-edit-link")
      edit_link.click

      # page is on English locale on load
      expect(page).to have_css('select#documentation_locale_en')

      # translations work
      select 'Español', from: 'documentation_locale_en'
      expect(page).to have_css('select#documentation_locale_es')

      # testing content
      fill_in_content
      click_on 'Update Documentation'

      expect(Documentation.last.reload.summary_content.text).to eq('my summary content')
      expect(Documentation.last.reload.page_title.text).to eq('my page title')
      expect(Documentation.last.reload.page_content.text).to eq('my page content')

      # redirects to the correct page
      expect(page).to have_content('New Loan')
    end

    scenario 'flow 3 on basic project show' do
      visit admin_basic_project_path(project)

      popover_link = page.find(:css, "a#basic_projects-show-title-link")
      popover_link.click

      new_link = page.find(:css, "a#basic_projects-show-title-new-link")
      new_link.click

      fill_in_content
      click_on "Create Documentation"

      documentation_created

      # redirects to the correct page
      expect(page).to have_content(project.display_name)
    end

    scenario 'flow 4 on loan index' do
      visit admin_loans_path

      popover_link = page.find(:css, "a#loans-index-title-link")
      popover_link.click

      new_link = page.find(:css, "a#loans-index-title-new-link")
      new_link.click

      fill_in_content
      click_on "Create Documentation"

      documentation_created

      # redirects to the correct page
      expect(page).to have_content("Loans")
      expect(page).to have_content("New Loan")
    end

    scenario 'flow 5 on loan detail' do
      visit admin_loan_path(loan)

      popover_link = page.find(:css, "a#loans-show-title-link")
      popover_link.click

      new_link = page.find(:css, "a#loans-show-title-new-link")
      new_link.click

      fill_in_content
      click_on "Create Documentation"

      documentation_created

      # redirects to the correct page
      expect(page).to have_content("Edit Loan")
      expect(page).to have_content("Delete Loan")
    end
  end

  scenario 'show page' do
    visit admin_documentation_path(doc)

    expect(page).to have_content('original page title')
    expect(page).to have_content('original page content')
  end

  def fill_in_content
    fill_in 'Summary Content', with: 'my summary content'
    fill_in 'Page Title', with: 'my page title'
    fill_in 'Page Content', with: 'my page content'
  end

  def documentation_created
    expect(Documentation.last.summary_content.text).to eq('my summary content')
    expect(Documentation.last.page_title.text).to eq('my page title')
    expect(Documentation.last.page_content.text).to eq('my page content')
    expect(page).to have_content "successfully created"
  end
end
