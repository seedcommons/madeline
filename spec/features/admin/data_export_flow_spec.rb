require 'rails_helper'

feature 'data export flow' do
  let(:user) { create_admin(root_division) }
  before do
    login_as(user, scope: :user)
  end
  scenario "create export with custom name and choose dates and choose a different locale" do
    start_date = Time.zone.today.beginning_of_year
    end_date = Time.zone.today
    visit admin_data_exports_path
    click_on "New Data Export"

    # TODO: find better way to test the special-case behavior when there is only one type
    # click_on "Standard Loan Data Export"
    fill_in 'data_export_start_date', with: Time.zone.today.beginning_of_year.to_s
    fill_in 'data_export_end_date', with: Time.zone.today.to_s
    fill_in 'Name', with: "Test"
    expect(page).to have_field('Locale code', with: 'en')
    select "es", from: 'Locale code'
    click_on "Create Data export" #TODO get Elizabeth's help making this upper case in markup, not just css
    expect(page).to have_content "Successfully queued data export."
    expect(page).to have_content "Test"
    expect(page).to have_content "Pending"
    saved_data_export = DataExport.first
    expect(saved_data_export.name).to eq "Test"
    expect(saved_data_export.start_date).to eq start_date.beginning_of_day
    expect(saved_data_export.end_date).to eq end_date.beginning_of_day
    expect(saved_data_export.locale_code).to eq 'es'
  end

  scenario "dates and name are optional and name has reasonable default" do
    visit new_admin_data_export_path
    expect(page).to have_field('Locale code', with: 'en')
    click_on "Create Data export"
    expect(page).to have_content('Standard Loan Data Export on')
  end
end
