require 'rails_helper'

describe QuestionSet, type: :model do
  let!(:division) { create(:division) }

  it 'has a valid factory' do
    expect(create(:question_set)).to be_valid
  end
end
