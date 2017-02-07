require 'rails_helper'

feature 'loan flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_member_access, :with_password, division: division).user }
  let!(:loan) { create(:loan, division: division) }

  before do
    login_as(user, scope: :user)
  end

  scenario 'should work', js: true do
    visit(admin_loans_path)
    expect(page).to have_content(loan.name)
  end
end
