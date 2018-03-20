require 'rails_helper'

feature 'people flow' do

  let(:division) { create(:division) }
  let(:user_1) { create_admin(division) }
  let(:user_2) { create_member(division) }
  let!(:person_1) { user_1.profile }
  let!(:person_2) { user_2.profile }
  let!(:log) { create(:project_log, agent: person_2) }

  before do
    login_as(user_1, scope: :user)
  end

  include_examples :flow do
    subject { person_1 }
    let(:field_to_change) { 'first_name' }
  end

  scenario 'person can be deleted' do
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
  end
end
