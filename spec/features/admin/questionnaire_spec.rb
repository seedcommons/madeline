require 'rails_helper'

# TODO: look for a way around targeting summernote textarea
feature 'questionnaire', js: true do
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
      page.find(".edit-all", match: :first).click
      expect(page).to have_content("Now editing")
      save_and_open_page

      # cancel button is visible in edit mode
      edit_bar = page.find("#editBar")
      edit_bar.find(".cancel-edit").click()
      expect(page).not_to have_content("Now editing")

      # save changes button is visible in edit mode
      page.find(".edit-all", match: :first).click
      expect(page).to have_content("Now editing")
      click_button 'Save Changes'
      expect(page).not_to have_content("Now editing")

      #fill_in('response_set[summary[text]]', with: 'kittens jumping on rainbows')
      # click_button 'Save Responses'
      # expect(page).to have_content 'successfully created'
      # expect(page).to have_content 'kittens jumping on rainbows'
      # expect(criteria.summary.text).to eq 'kittens jumping on rainbows'
      #
      # # edit
      # click_link('Edit Responses')
      # fill_in('response_set[summary[text]]', with: 'sexy unicorns')
      # click_button 'Save Responses'
      # expect(page).to have_content 'successfully updated'
      # expect(page).to have_content 'sexy unicorns'
      # expect(page).not_to have_content 'Warning'
      # expect(criteria.summary.text).to eq 'sexy unicorns'
      #
      # # delete
      # accept_confirm { click_link('Delete All Responses') }
      # expect(page).to have_content 'successfully deleted'
      # expect(page).not_to have_content 'sexy unicorns'
      # # After deletion, should be in edit mode
      # expect(page).not_to have_content 'Edit Responses'
      # expect(page).to have_selector 'input[value="Save Responses"]'
    end
  end

  context 'with conflicting changes' do
    let(:response_set) { criteria }

    before do
      response_set.summary = {text: 'dragon'}
      response_set.save!

      visit admin_loan_tab_path(loan, 'questions')
      click_link('Edit Responses')
      fill_in('response_set[summary[text]]', with: 'gnashing teeth')
      response_set.touch
      click_button 'Save Responses'
    end

    it "raises an error and discard button works" do
      # Check that warning message is displayed
      expect(page).to have_content 'Warning'
      expect(page).to have_selector 'input[type="submit"][name="overwrite"]'

      # Check that discard button works
      find('input[type="submit"][name="discard"]').click
      expect(page).not_to have_content 'Warning'
      expect(page).to have_content 'dragon'
      expect(criteria.summary.text).to eq 'dragon'
    end

    it "overwrite button works" do
      find('input[type="submit"][name="overwrite"]').click
      expect(page).to have_content 'successfully updated'
      expect(page).to have_content 'gnashing teeth'
      expect(criteria.summary.text).to eq 'gnashing teeth'
    end
  end

  #  finds and reloads/creates criteria and assigns current user
  def criteria
    c = loan.criteria ? loan.criteria.reload : loan.create_criteria
    c.current_user = user
    c
  end
end
