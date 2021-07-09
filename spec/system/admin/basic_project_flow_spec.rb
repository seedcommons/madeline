require 'rails_helper'

describe 'basic project flow' do

  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let!(:basic_project) { create(:basic_project, division: division) }
  let(:parent_group) { create(:project_group) }
  let!(:child_group) { create(:project_group, project: basic_project, parent: parent_group) }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    subject { basic_project }
    let(:edit_button_name) { 'Edit Project' }
  end

  scenario 'validations for creating basic project' do
    visit new_admin_basic_project_path
    select user.name, from: 'basic_project_primary_agent_id'
    select user.name, from: 'basic_project_secondary_agent_id'
    click_on 'Create Basic project'
    expect(page).to have_content('The point person for this project cannot be the same as the second point person')
  end

  scenario 'validations for updating basic project' do
    visit admin_basic_projects_path
    click_on basic_project.id.to_s
    select user.name, from: 'basic_project_primary_agent_id'
    select user.name, from: 'basic_project_secondary_agent_id'
    click_on 'Update Basic project'
    expect(page).to have_content('The point person for this project cannot be the same as the second point person')
  end

  scenario 'loan with groups can be deleted' do
    visit admin_basic_project_path(basic_project)
    click_on 'Delete Project'
    expect(page).to have_content('Record was successfully deleted')
  end

  scenario 'project with groups can be duplicated' do
    visit admin_basic_project_path(basic_project)
    click_on 'Duplicate Project'
    expect(page).to have_content('The project was successfully duplicated.')
    expect(page).to have_content("Copy of #{basic_project.name}")
  end
end
