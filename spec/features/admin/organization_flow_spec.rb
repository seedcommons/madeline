require 'rails_helper'

feature 'organization flow' do
  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let!(:org1) { create(:organization, division: division) }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    subject { org1 }
    let(:edit_button_name) { 'Edit Co-op' }
  end
end
