require 'rails_helper'

feature 'data export flow' do
  let(:division) { create(:division) }
  let(:user) { create_admin(division) }
  before do
    login_as(user, scope: :user)
  end
  scenario "create export with custom name and choose dates" do
    visit new_admin_data_export_path
    click_on "Standard Loan Data Export"
    fill_in 'data_export_start_date', with: Time.zone.today.beginning_of_year.to_s
    fill_in 'data_export_end_date', with: Time.zone.today.to_s
    fill_in 'Name', with: "Test"
    expect(page).to have_field('Locale code', with: 'en')
    click_on "Create Data export"

    # TODO replace with show page check
    saved_data_export = DataExport.first
    expect(saved_data_export.name).to eq "Test"
  end

  scenario "dates and name are optional and name has reasonable default" do
    visit new_admin_data_export_path
    click_on "Standard Loan Data Export"
    expect(page).to have_field('Locale code', with: 'en')
    click_on "Create Data export"

    # TODO replace with show page check
    saved_data_export = DataExport.first
    expect(saved_data_export.name).to include("Data Export")
  end
end
