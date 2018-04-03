require 'rails_helper'

feature 'people flow' do

  let!(:division) { create(:division) }
  let(:log) { build(:project_log) }
  let!(:person_1) { create(:person, :with_admin_access, :with_password, project_logs: [log]) }
  let!(:person_2) { create(:person, :with_member_access, :with_password, project_logs: [log]) }
  let(:user_1) { person_1.user }
  let(:user_2) { person_2.user }
  let(:loan) { create(:loan, division: division, representative: person_1) }

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
      within('ul.hidden-print') do
        click_on 'Logs'
      end

      save_and_open_page
    end


    # During QA, I found this bug. After deleting the member that had logs and trying
    # to visit the logs page for a specific loan (the loan related to the log),the page errors out.
    # See the error below. Additionally, the related step's modal cannot be opened from the timeline.
  end
end
