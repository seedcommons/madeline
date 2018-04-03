require 'rails_helper'

feature 'people flow' do

  let!(:division) { create(:division) }
  let(:person_1) { create(:person, :with_admin_access, :with_password) }
  let(:person_2) { create(:person, :with_member_access, :with_password) }
  let(:loan) { create(:loan, division: division, primary_agent: person_1, secondary_agent: person_2) }
  let(:step) { create(:project_step, project: loan) }
  let!(:log_1) { create(:project_log, agent: person_1, project_step: step) }
  let!(:log_2) { create(:project_log, agent: person_2, project_step: step) }
  let(:user_1) { person_1.user }

  before do
    login_as(user_1, scope: :user)
  end

  include_examples :flow do
    subject { person_1 }
    let(:field_to_change) { 'first_name' }
  end

  context 'logs' do
    scenario 'person with log can be deleted' do
      visit admin_people_path

      # persons exists
      expect(page).to have_content(person_1.first_name)
      expect(page).to have_content(person_2.first_name)

      # delete actiopn
      click_on person_2.id
      click_on 'Delete Member'

      # person no longer exists
      expect(page).to have_content('Record was successfully deleted.')
      expect(page).not_to have_content(person_2.first_name)

      # visit the logs page that have logs of person deleted
      visit admin_loan_path(loan)
      within 'ul.hidden-print' do
        click_on 'Logs'
      end

      # logs, with or without users are still available
      expect(all('.log.post').size).to eq 2
    end
  end
end
