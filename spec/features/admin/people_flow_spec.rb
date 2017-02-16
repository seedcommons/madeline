require 'rails_helper'

feature 'people flow' do

  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let(:person) { user.profile }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    subject { person }
    let(:field_to_change) { "first_name" }
  end
end
