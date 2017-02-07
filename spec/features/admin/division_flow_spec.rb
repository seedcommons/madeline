require 'rails_helper'

feature 'division flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_admin_access, :with_password, division: division).user }

  before do
    login_as(user, scope: :user)
  end

  scenario 'should work', js: true do
    visit(admin_divisions_path)
    expect(page).to have_content(division.name)
  end
end
