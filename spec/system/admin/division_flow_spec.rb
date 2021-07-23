require "rails_helper"

describe "division flow", js: true do
  let!(:division) { create(:division, name: 'Cream', short_name: 'cream') }
  let!(:qb_department) { create(:department, name: "QB Dep") }
  let(:person) { create(:person, :with_admin_access, :with_password) }
  let(:user) { person.user }

  before do
    allow(SecureRandom).to receive(:uuid) { 'iamauuid2018' }
    login_as(user, scope: :user)
  end

  scenario "index" do
    visit(admin_divisions_path)
    expect(page).to have_title("Divisions")
    expect(page).to have_content("Cream")
  end

  scenario "show/edit/update" do
    visit(admin_divisions_path)
    within("#divisions") { click_link(division.id.to_s) }

    expect(page).to have_title("Cream")
    find("a", text: "Edit Division").click

    fill_in("* Name", with: "New Name", exact: true)
    select("QB Dep", from: "QB Division")
    click_button("Update Division")

    expect(page).to have_content("New Name")
    expect(page).to have_content("QB Dep")
    expect(page).to have_content('Record was successfully updated.')
  end

  # TODO: this should be a model spec
  scenario "division and parent division can't be the same" do
    visit admin_division_path(division)
    find('.edit-action').click
    select 'Cream', from: 'division_parent_id'
    click_on 'Update Division'
    expect(page).to have_content('Division and Parent Division cannot be the same')
  end

  # TODO: this should be a model spec
  scenario 'divisions can not have duplicate short names' do
    visit admin_divisions_path
    click_on 'New Division'
    fill_in 'division_name', with: 'Jay'
    fill_in 'Short Name', with: 'cream'
    click_on 'Create Division'
    expect(page).to have_content('jay-iamauuid2018')

    # on edit
    visit admin_division_path(Division.last)
    find('.edit-action').click
    fill_in 'Short Name', with: 'cream'
    click_on 'Update Division'
    expect(page).to have_content('jay')
  end
end
