# == Schema Information
#
# Table name: question_sets
#
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  internal_name :string
#  updated_at    :datetime         not null
#

require 'rails_helper'

describe QuestionSet, type: :model do
  let!(:division) { create(:division) }

  it 'has a valid factory' do
    expect(create(:question_set)).to be_valid
  end
end
