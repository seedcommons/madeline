require "rails_helper"

describe "division flow", js: true do
  let!(:division) { create(:division, name: "Cream", short_name: "cream") }
  let!(:qb_department) { create(:department, name: "QB Dep") }
  let(:person) { create(:person, :with_admin_access, :with_password) }
  let(:user) { person.user }

  before do
    allow(SecureRandom).to receive(:uuid) { "iamauuid2018" }
    login_as(user, scope: :user)
  end

  scenario "index" do
    visit(admin_divisions_path)
    expect(page).to have_title("Divisions")
    expect(page).to have_content("Cream")
  end

  scenario "new/create" do
    visit(admin_divisions_path)
    click_on("New Division")

    fill_in("* Name", with: "New Division", exact: true)
    select("Cream", from: "Parent Division")

    click_button("Create Division")

    expect(page).to have_alert("Record was successfully created.")
    expect(page).to have_content("New Division")
    expect(page).to have_content("Cream")
  end

  scenario "show/edit/update" do
    visit(admin_divisions_path)
    within("#divisions") { click_link(division.id.to_s) }

    expect(page).to have_title("Cream")
    find("a", text: "Edit Division").click

    expect(page).to have_field("Parent Division", disabled: true)
    fill_in("* Name", with: "New Name", exact: true)
    fill_in("Division Homepage", with: "www.example.coop")
    select("QB Dep", from: "QB Division")
    click_button("Update Division")

    expect(page).to have_content("New Name")
    expect(page).to have_content("QB Dep")
    expect(page).to have_content("www.example.coop")
    expect(page).to have_alert("Record was successfully updated.")
  end


  # good place to add spec about changing the shortname
  scenario 'visit public page after changing short name' do
    visit admin_division_path(division)

    #confirm short name is not "newshort" yet
    public_url_section = find(".division_public_url a", match: :first)
      expect(public_url_section).not_to have_content("newshort")

    # visit public page with current shortname
    find(".division_public_url a", match: :first).click
    expect(page).to have_content(division.name)
    expect(URI.parse(current_url)).to have_content(division.short_name)

    # return to admin division form and update shortname
    visit admin_division_path(division)

    page.find('.edit-action', text: 'Edit Division').click
    fill_in 'Short Name', with: 'newshort'
    click_on 'Update Division'
    expect(page).to have_content(division.name)


    # confirm shortname update took effect in public url
    visit admin_division_path(division)
    public_url_section = find(".division_public_url a", match: :first)
      expect(public_url_section).to have_content("newshort")
    find(".division_public_url a", match: :first).click

    expect(URI.parse(current_url)).to have_content("newshort")
  end

  context 'editing qb department' do
    let!(:departments) {
      %w(Dep1 Dep2 Dep3).map do |name|
        create(:department, name: name)
      end
    }
    scenario 'set department' do
      visit admin_division_path(division)
      find('.edit-action').click
      select 'Dep2', from: 'division_qb_department_id'
      click_on 'Update Division'
      expect(page.find('.division_qb_department_id .view-element')).to have_content('Dep2')
    end
  end

  scenario 'editing colors' do
    visit admin_division_path(division)
    find('.edit-action').click
    fill_in 'Madeline Primary Color', with: 'blue'
    fill_in 'Madeline Secondary Color', with: 'purple'
    fill_in 'Madeline Accent Color', with: 'red'
    fill_in "Public Division Page Primary Color", with: 'green'
    fill_in "Public Division Page Secondary Color", with: 'orange'
    fill_in "Public Division Page Accent Color", with: 'teal'
    click_on 'Update Division'
    visit admin_division_path(division)
    # TODO: test colors on admin page
    # TODO: test colors on public
  end
end
