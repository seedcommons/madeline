require 'rails_helper'

describe 'visit tasks show page page' do
  context 'has custom error data' do
    before do
      login_as(user, scope: :user)
    end

    let(:division) { Division.root }
    let(:user) { create_admin(division) }
    let!(:task) {
      create(:task, custom_error_data: [{loan_id: 1, message: "Message 1"}, {loan_id: 2, message: "Message 2"}])
    }

    it 'displays custom error data' do
      visit admin_task_path(task.id)
      expect(page).to have_content('Error Details')
    end
  end
end
