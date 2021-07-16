require 'rails_helper'

describe 'people flow' do

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

  include_examples :flow do
    subject { person_1 }
    let(:field_to_change) { 'first_name' }
  end

  context 'logs' do
    scenario 'person with log can be deleted' do
      confirm_both_users_exist

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
    before do
      login_as(user_2, scope: :user)
    end

    scenario 'person with notes can be deleted' do
      # create note with second user as author
      visit admin_organization_path(org)
      click_on 'New Note'

      fill_in 'note_text', with: 'Note from second user'

      within('.note-form') do
        click_on 'Save'
      end

      # logout second person (with note)
      logout user_2

      # login first person
      login_as(user_1, scope: :user)

      confirm_both_users_exist

      then_delete_second_user

      # notes without users are still available
      visit admin_organization_path(org)
      within(all('.note.post')[0]) do
        expect(page).to have_content('Note from second user')
        expect(page).to have_content('Deleted User')
      end
    end
  end

  def confirm_both_users_exist
    visit admin_people_path

    expect(page).to have_content(person_1.first_name)
    expect(page).to have_content(person_2.first_name)
  end

  def then_delete_second_user
    click_on person_2.id.to_s
    click_on 'Delete Member'

    # second person no longer exists
    expect(page).to have_content('Record was successfully deleted.')
    expect(page).not_to have_content(person_2.first_name)
  end
end
