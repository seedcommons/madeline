require 'rails_helper'

feature 'loan flow' do
  let(:division) { create(:division) }
  let(:user) { create(:person, :with_member_access, :with_password, division: division).user }
  let!(:loan) { create(:loan, division: division) }

  before do
    login_as(user, scope: :user)
  end

  # This should work, but for some reason it fails a lot more often
  include_examples :flow do
    let(:model_to_test) { loan }
  end

  # Keeping this code here for now. It tended to be more stable than the shared example.
  # Can be deleted when we are happy the shared spec is working.
  # scenario 'can view index', js: true do
  #   visit(admin_loans_path)
  #   expect(page).to have_content(loan.name)
  #
  #   within('#loans') do
  #     click_link(loan.id)
  #   end
  #
  #   expect(page).to have_content("##{loan.id}: #{loan.name}")
  #
  #   visit(admin_loan_path(id: loan.id))
  #   expect(page).to have_content("##{loan.id}: #{loan.name}", wait: 10)
  #   expect(page).to have_content('Edit Loan')
  #
  #   find('.edit-action').click
  #
  #   expect(page).to have_css('#loan_name', visible: true, wait: 10)
  #   fill_in('loan[name]', with: 'Changed Loan Name')
  #
  #   click_button 'Update Loan', wait: 10
  #   expect(page).to have_content("##{loan.id}: Changed Loan Name")
  #   expect(page).to have_content('Record was successfully updated.')
  # end
end
