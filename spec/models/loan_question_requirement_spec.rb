require 'rails_helper'

describe LoanQuestionRequirement, type: :model do

  it 'has a valid factory' do
    expect(create(:loan_question_requirement)).to be_valid
  end

end
