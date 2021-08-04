require 'rails_helper'

describe 'data export flow' do
  let(:user) { create_admin(root_division) }
  before do
    login_as(user, scope: :user)
  end
  scenario "create export with custom name and choose dates and choose a different locale" do
    start_date = Time.zone.today.beginning_of_year
    end_date = Time.zone.today
    visit admin_data_exports_path
    click_on "New Data Export"

    click_on "Standard Loan Data Export"

    fill_in 'data_export_start_date', with: Time.zone.today.beginning_of_year.to_s
    fill_in 'data_export_end_date', with: Time.zone.today.to_s
    fill_in 'Name', with: "Test"
    expect(page).to have_field(I18n.t('activerecord.attributes.data_export.locale_code'), with: 'en')
    select I18n.t('locale_name.es'), from: I18n.t('activerecord.attributes.data_export.locale_code')
    click_on "Create Data Export"
    expect(page).to have_content "Successfully queued data export."
    expect(page).to have_content "Test"
    expect(page).to have_content "Pending"
    click_on "1" # link to data export show page
    expect(page).to have_content "Jan 1" # start time
    expect(page).to have_content "#{Time.zone.today.year} 12:00 AM" # end time
    expect(page).to have_title "Test"
    expect(page).to have_content "Associated Task"
    click_on "1" # link to task show
    expect(page).to have_content "Data Export Task"
    saved_data_export = DataExport.first
    expect(saved_data_export.locale_code).to eq 'es'
  end

  scenario "dates and name are optional and name has reasonable default" do
    visit new_admin_data_export_path
    click_on "Standard Loan Data Export"
    expect(page).to have_field(I18n.t("activerecord.attributes.data_export.locale_code"), with: 'en')
    click_on "Create Data Export"
    expect(page).to have_content('Standard Loan Data Export on')
  end
end
