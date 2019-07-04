require 'rails_helper'

feature 'visit tasks index page' do
  context 'there are tasks' do
    before do
      login_as(user, scope: :user)
    end

    let(:division) { Division.root }
    let(:user) { create_admin(division) }
    let(:tasks) {
      3.times {create(:task)}
    }

    it 'shows tasks in descending order of creation' do
      tasks
      expect(Task.count).to eq 3
      visit admin_tasks_path
      expect(page).to have_content('Tasks')
      expect(page).to have_css("tr", count: 4)
    end
  end
end
