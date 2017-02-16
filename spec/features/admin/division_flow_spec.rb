require 'rails_helper'

feature 'division flow' do

  let(:division) { create(:division) }
  let(:user) { create_admin(division) }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    subject { division }
  end
end
