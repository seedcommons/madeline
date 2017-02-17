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
end
