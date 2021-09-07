require 'rails_helper'

# TODO: look for a way around targeting summernote textarea
describe 'questionnaire', js: true do
  let!(:division) { create(:division) }
  let(:user) { create_member(division) }
  let(:loan) { create(:loan, division: division) }
  let!(:question_set) { create(:question_set, :loan_criteria) }

  before do
    login_as(user, scope: :user)
  end

  context 'happy path' do
    it "works" do
      # create
      visit admin_loan_tab_path(loan, 'questions')

      # check that edit-all button turns on edit mode
      expect(page).not_to have_content("Now editing")
      first(".edit-all").click()
      expect(page).to have_content("Now editing")

      # cancel button is visible in edit mode
      first("#edit-bar .cancel-edit").click
      expect(page).not_to have_content("Now editing")

      # save changes button is visible in edit mode
      first(".edit-all").click()
      expect(page).to have_content("Now editing")
      click_button('Save Changes')
      expect(page).not_to have_content("Now editing")

      # test outline expansion
      expect(page).not_to have_content("Outline")
      page.find(".outline .expander").click()
      expect(page).to have_content("Outline")
      page.find(".outline .hider").click()
      expect(page).not_to have_content("Outline")
    end
  end

  context 'with conflicting changes' do
    # TODO reimplement
  end

  # finds and reloads/creates criteria
  def criteria
    loan.criteria ? loan.criteria.reload : loan.create_criteria
  end
end
