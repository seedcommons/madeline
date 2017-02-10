require 'rails_helper'

feature 'division flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_admin_access, :with_password, division: division).user }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    let(:model_to_test) { division }
  end
end
