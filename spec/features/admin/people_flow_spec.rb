require 'rails_helper'

feature 'people flow' do

  let(:division) { create(:division) }
  let(:person) { create(:person, :with_member_access, :with_password, division: division) }
  let(:user) { person.user }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    let(:model_to_test) { person }
    let(:field_to_change) { "first_name" }
  end
end
