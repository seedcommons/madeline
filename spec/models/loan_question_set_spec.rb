require 'rails_helper'

describe LoanQuestionSet, :type => :model do
  it 'has a valid factory' do
    expect(create(:loan_question_set)).to be_valid
  end
end
