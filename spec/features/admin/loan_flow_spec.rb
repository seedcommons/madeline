require 'rails_helper'

feature 'loan flow' do
  let(:division) { create(:division) }
  let(:user) { create(:person, :with_member_access, :with_password, division: division).user }
  let!(:loan) { create(:loan, division: division) }

  before do
    login_as(user, scope: :user)
  end

  scenario 'can view index', js: true do
    visit(admin_loans_path)
    expect(page).to have_content(loan.name)

    within('#loans') do
      click_link(loan.id)
    end

    expect(page).to have_content("##{loan.id}: #{loan.name}")

    visit(admin_loan_path(id: loan.id))
    expect(page).to have_content("##{loan.id}: #{loan.name}")
    expect(page).to have_content('Edit Loan')

    find('.edit-action').click

    expect(find('#loan_name')).to have_content(loan.name)
    fill_in('loan[name]', with: 'Changed Loan Name')

    click_button 'Update Loan'
    expect(page).to have_content("##{loan.id}: Changed Loan Name")
    expect(page).to have_content('Record was successfully updated.')
  end
end
