require 'rails_helper'

describe 'people flow', js: true do

  let!(:division) { create(:division) }
  let!(:org) { create(:organization) }
  let(:person_1) { create(:person, :with_admin_access, :with_password) }
  let(:person_2) { create(:person, :with_member_access, :with_password) }
  let(:loan) { create(:loan, division: division, primary_agent: person_1, secondary_agent: person_2) }
  let(:step) { create(:project_step, project: loan) }
  let!(:log_1) { create(:project_log, agent: person_1, project_step: step) }
  let!(:log_2) { create(:project_log, agent: person_2, project_step: step) }
  let(:user_1) { person_1.user }
  let(:user_2) { person_2.user }

  before do
    login_as(user_1, scope: :user)
  end

  include_examples "flow" do
    subject { person_1 }
    let(:field_to_change) { 'first_name' }
  end

  context 'create, update' do
    scenario do
      visit(admin_people_path)
      click_on("New Member")
      fill_in("person_first_name", with: "Ruddiger")
      fill_in("person_email", with: "ruddiger@example.com")
      check("person_has_system_access")
      select("Member", from: "person_access_role")

      # Check correct default
      expect(page).to have_select("person_notification_source", selected: "Home division only")
      select("Home division and subdivisions", from: "person_notification_source")

      fill_in("person_password", with: "jfjfjfjfjfjfj")
      fill_in("person_password_confirmation", with: "jfjfjfjfjfjfj")
      click_on("Create Member")

      expect(page).to have_alert("Record was successfully created")
      expect(page).to have_content("Notifications\nHome division and subdivisions")
      find(".edit-action", text: "Edit Member").click

      expect(page).to have_select("person_notification_source", selected: "Home division and subdivisions")
      select("Off", from: "person_notification_source")
      click_on("Update Member")

      expect(page).to have_alert("Record was successfully updated")
      expect(page).to have_content("Notifications\nOff")
    end
  end

  context 'logs' do
    scenario 'person with log can be deleted' do
      visit admin_people_path

      expect(page).to have_content(person_1.first_name)
      expect(page).to have_content(person_2.first_name)

      # visit the logs page that have logs of person deleted
      visit admin_loan_path(loan)
      within 'ul.hidden-print' do
        click_on 'Logs'
      end

      # logs, with or without users are still available
      expect(all('.log.post').size).to eq 2
    end
  end

  context 'notes' do
    let!(:note) { create(:note, author: person_2, notable: org, text: "Note from second user") }

    scenario 'person with notes can be deleted' do
      visit admin_people_path

      expect(page).to have_content(person_1.first_name)
      expect(page).to have_content(person_2.first_name)

      click_on person_2.id.to_s
      accept_confirm { click_on 'Delete Member' }

      # second person no longer exists
      expect(page).to have_content('Record was successfully deleted.')
      expect(page).not_to have_content(person_2.first_name)

      # notes without users are still available
      visit admin_organization_path(org)
      expect(page).to have_content('Note from second user')
      expect(page).to have_content('Deleted User')
    end
  end
end
