require "rails_helper"

feature "organization flow" do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_member_access, :with_password, division: division).user }
  let!(:org1) { create(:organization, division: division) }

  before do
    login_as(user, scope: :user)
  end

  scenario "should work", js: true do
    visit(admin_organizations_path)
    expect(page).to have_content(org1.name)
  end
end
