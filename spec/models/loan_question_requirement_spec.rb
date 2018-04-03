# == Schema Information
#
# Table name: loan_question_requirements
#
#  amount      :decimal(, )
#  id          :integer          not null, primary key
#  option_id   :integer
#  question_id :integer
#

require 'rails_helper'

describe LoanQuestionRequirement, type: :model do
  let!(:division) { create(:division) }

  it 'has a valid factory' do
    expect(create(:loan_question_requirement)).to be_valid
  end

end
