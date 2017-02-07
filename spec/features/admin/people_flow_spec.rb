require 'rails_helper'

feature 'people flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_member_access, :with_password, division: division).user }

  before do
    login_as(user, scope: :user)
  end

  scenario 'should work', js: true do
    visit(admin_people_path)
    expect(page).to have_content(user.name)
  end
end
