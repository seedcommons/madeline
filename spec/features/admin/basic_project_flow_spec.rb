require 'rails_helper'

feature 'basic project flow' do

  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let!(:basic_project) { create(:basic_project, division: division) }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    subject { basic_project }
    let(:edit_button_name) { 'Edit Project' }
  end

  scenario 'validations for pry and sec agents' do
    visit new_admin_basic_project_path
    select user.name, from: 'basic_project_primary_agent_id'
    select user.name, from: 'basic_project_secondary_agent_id'
    click_on 'Create Basic project'
    expect(page).to have_content('The point person for this project cannot be the same as the second point person')
  end
end
