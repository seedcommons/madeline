require 'rails_helper'
include QuestionSpecHelpers

feature 'manage loan questions', js: true do
  let!(:d1) { create(:division) }
  let(:user) { create(:user, :admin, division: d1) }
  let(:d11) { create(:division, parent: d1) }
  let!(:qset) { create(:loan_question_set, internal_name: 'loan_criteria') }
  let!(:q1) { create_question(division: d1, type: :string, parent: qset.root_group) }

  let!(:g11) { create_group(division: d11, parent: qset.root_group) }
  let!(:q11) { create_question(type: :text, parent: g11) }

  before do
    q1.set_label('ice cream')
    g11.set_label('corn bread')
    q11.set_label('veggies')

    # set_label does not save the translation object
    q1.save
    g11.save
    q11.save

    login_as user

    visit admin_loan_questions_path
  end

  scenario 'parent division selected' do
    select_division(d1.name)

    expect(page).to have_content('ice cream')
    expect(page).not_to have_content('corn bread')
    expect(page).not_to have_content('veggies')
  end

  scenario 'child division selected' do
    select_division(d11.name)
    find('.jqtree-toggler').click

    expect(page).to have_content('ice cream')
    expect(page).to have_content('corn bread')
    expect(page).to have_content('veggies')
  end

  scenario 'all divisions selected' do
    select_division('All Divisions')
    find('.jqtree-toggler').click

    expect(page).to have_content('ice cream')
    expect(page).to have_content('corn bread')
    expect(page).to have_content('veggies')
  end
end
