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

  scenario 'basic project can not be created with the same person as pry and sec agent' do
    visit new_admin_basic_project_path
    select user.name, from: 'basic_project_primary_agent_id'
    select user.name, from: 'basic_project_secondary_agent_id'
    click_on 'Create Basic project'
    expect(page).to have_content('The primary agent for this project cannot be the same as the secondary agent')
  end
end
