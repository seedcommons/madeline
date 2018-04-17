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

  scenario 'saving loan redirects to coop page' do
    visit admin_organization_path(org1)
    click_on 'New Loan'
    click_on 'Create Loan'

    expect(page).to have_content('Record was successfully created.')
    expect(page).to have_content(org1.name)
    expect(page).not_to have_content('Transactions')
  end
end
