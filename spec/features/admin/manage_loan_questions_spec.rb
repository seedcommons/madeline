require 'rails_helper'
include QuestionSpecHelpers

feature 'manage loan questions', js: true do
  let!(:d1) { create(:division) }
  let!(:user) { create(:user, :admin, division: d1) }
  let!(:d11) { create(:division, parent: d1) }
  let!(:qset) { create(:loan_question_set, internal_name: 'loan_criteria') }
  let!(:q1) { create_question(division: d1, type: :string, parent: qset.root_group, name: 'ice cream') }

  let!(:g11) { create_group(division: d11, parent: qset.root_group, name: 'corn bread') }
  let!(:q11) { create_question(type: :text, parent: g11, name: 'veggies') }

  before do
    q1.set_explanation('ice cream')
    g11.set_explanation('corn bread')
    q11.set_explanation('veggies')

    login_as user

    visit admin_loan_questions_path
  end

  scenario 'parent division selected' do
    within('.user-div-info') do
      select_division(d1.name)
    end
    save_and_open_page
    expect(page).to have_content('ice cream')
    expect(page).not_to have_content('corn bread')
    expect(page).not_to have_content('veggies')
  end

  # scenario 'child division selected' do
  #   select_division(d11.name)
  #   expect(page).to have_content('ice cream')
  #   expect(page).to have_content('corn bread')
  #   expect(page).to have_content('veggies')
  # end
  #
  # scenario 'all divisions selected' do
  #   select_division("All Divisions")
  #   expect(page).to have_content('ice cream')
  #   expect(page).to have_content('corn bread')
  #   expect(page).to have_content('veggies')
  # end
end
