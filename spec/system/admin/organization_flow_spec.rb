require 'rails_helper'

describe 'organization flow', js: true do
  let(:currency) { create(:currency) }
  let(:division) { create(:division, currency_id: currency.id) }
  let(:admin) { create_admin(division) }
  let(:user) { create_member(division) }
  let!(:org1) { create(:organization, division: division) }
  # add country to correspond to currency in factories
  let!(:country) { create(:country, iso_code: 'US', name: 'United States') }

  before do
    # add profile name for user
    @u_profile = user.profile
    @u_profile.first_name = 'Jay'
    @u_profile.last_name = 'Mem'
    @u_profile.save

    # add profile name for admin
    a_profile = admin.profile
    a_profile.first_name = 'Jay'
    a_profile.last_name = 'Admin'
    a_profile.save

    # login as user
    login_as(user, scope: :user)

    visit("/")
    select_division(division)

    OptionSetCreator.new.create_public_level
    OptionSetCreator.new.create_organization_inception
  end

  include_examples "flow" do
    subject { org1 }
    let(:edit_button_name) { 'Edit Co-op' }
  end

  scenario 'coop creation' do
    visit new_admin_organization_path
    fill_in 'organization_name', with: 'Jayita'
    fill_in 'organization_postal_code', with: '47905' # req'd for country
    fill_in 'organization_state', with: 'IN'
    select country.name
    select 'Conversion', from: 'organization_inception_value'

    click_on 'Create Co-op'

    expect(page).to have_content('Jayita')
    expect(page).to have_content('Record was successfully created')
    expect(page).to have_current_path(admin_organization_path(Organization.last))
    expect(page).to have_content('United States')
    expect(page).to have_content('Conversion')
  end

  scenario 'saving loan redirects to coop page' do
    visit admin_organization_path(org1)
    click_on 'New Loan'
    click_on 'Create Loan'

    expect(page).to have_content('Record was successfully created.')
    expect(page).to have_content(org1.name)
    expect(page).not_to have_content('Transactions')
  end

  xscenario "filling in more details" do
    visit admin_organization_path(org1)
    click_on "Edit Co-op"
    fill_in "NAICS Code", with: "1234"
    fill_in "Census Tract Code", with: "xyz"
    select("LLC", from: "organization_entity_structure")
    #todo selecting date established
    click_on "Update Co-op"
    expect(page).to have_content("1234")
    expect(page).to have_content("xyz")
    expect(page).to have_content("Entity Structure\nLLC")
  end

  scenario 'notes are accessible when author is deleted', js: true do
    # user adds a note
    visit admin_organization_path(org1)
    click_on 'New Note'
    fill_in 'Note', with: 'You had better work'
    click_on 'Save'

    # user logs out
    find("#logout").click

    # admin user logs in
    fill_in 'user_email', with: admin.email
    fill_in 'user_password', with: admin.password
    click_on 'Login'

    # and deletes the author of the note
    visit admin_people_path
    click_on @u_profile.id.to_s
    accept_confirm { click_on 'Delete Member' }

    # when the organization with the note is visited
    visit admin_organization_path(org1)
    expect(page).to have_content(org1.name)
  end
end
