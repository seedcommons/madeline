# == Schema Information
#
# Table name: loan_question_sets
#
#  created_at    :datetime         not null
#  division_id   :integer
#  id            :integer          not null, primary key
#  internal_name :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_loan_question_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_13da1a92b4  (division_id => divisions.id)
#

require 'rails_helper'

describe LoanQuestionSet, :type => :model do
  it 'has a valid factory' do
    expect(create(:loan_question_set)).to be_valid
  end
end
