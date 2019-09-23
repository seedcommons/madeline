require 'rails_helper'

feature 'data export flow' do
  let(:division) { create(:division) }
  let(:user) { create_admin(division) }
  before do
    login_as(user, scope: :user)
  end
  scenario "create basic export" do
    visit new_admin_data_export_path
    click_on "Standard Loan Data Export"
    fill_in 'Start date', with: Date.today.beginning_of_year.to_s
    fill_in 'End date', with: Date.today.to_s
    fill_in 'Name', with: "Test"
    expect(page).to have_field('Locale code', with: 'en')
    click_on "Create Data export"

    #TODO replace with show page check
    saved_data_export = DataExport.first
    expect(saved_data_export.name).to eq "Test"

      # when I submit, then the data export is saved

  # the form will have a default name

  # the form will have a default locale

  # I can change the name

  # I can change the locale

  # start date and end date are optional

  # something about divisions???

    #TODO IN FUTURE ISSUES: there will be a show page
  end
end
