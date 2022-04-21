require 'rails_helper'

describe ResponseSet, js: true do
  let(:division) { create(:division) }
  let!(:question_set) { create(:question_set, :with_questions, kind: "loan_criteria", division: division)}
  let(:user) { create_member(division) }
  let(:loan) { create(:loan, division: division) }

  before do
    login_as(user, scope: :user)
  end



  def fill_and_save(type, value)
    first(".edit-all").click
    expect(page).to have_content("Now editing")
    find("input[type=#{type}]").set(value)
    find("body").click # Trigger blur event so that Save Changes button is properly clickable
    click_button("Save Changes")
    expect(page).not_to have_content("Now editing")
  end
end
