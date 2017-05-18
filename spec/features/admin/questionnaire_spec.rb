require 'rails_helper'

feature 'questionnaire', js: true do
  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let(:loan) { create(:loan, division: division) }
  # let(:loan_question_set) { create(:loan_question_set, :loan_criteria) }

  before do
    login_as(user, scope: :user)
    create(:loan_question_set, :loan_criteria)
  end

  context 'with conflicting changes' do
    let(:response_set) { loan.create_criteria }

    before do
      response_set.summary = { text: 'dragon' }
      response_set.save!
    end

    it "raises an error and discard button works" do
      # Check that warning message is displayed
      visit admin_loan_tab_path(loan, 'questions')
      click_link('Edit Responses')
      fill_in('loan_response_set[summary[text]]', with: 'breath of fire')
      response_set.touch
      click_button 'Save Responses'
      expect(page).to have_content 'Warning'
      expect(page).to have_selector 'input[type="submit"][name="overwrite"]'

      # Check that discard button works
      find('input[type="submit"][name="discard"]').click
      expect(page).not_to have_content 'Warning'
      expect(page).to have_content 'dragon'
      expect(response_set.reload.summary.text).to eq 'dragon'
    end

    it "overwrite button works" do
      visit admin_loan_tab_path(loan, 'questions')
      click_link('Edit Responses')
      fill_in('loan_response_set[summary[text]]', with: 'gnashing teeth')
      response_set.touch
      click_button 'Save Responses'
      find('input[type="submit"][name="overwrite"]').click
      expect(page).to have_content 'successfully updated'
      expect(page).to have_content 'gnashing teeth'
      expect(response_set.reload.summary.text).to eq 'gnashing teeth'
    end
  end
end
