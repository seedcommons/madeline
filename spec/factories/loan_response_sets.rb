# == Schema Information
#
# Table name: loan_response_sets
#
#  id                         :integer          not null, primary key
#  loan_question_addable_id   :integer
#  loan_question_addable_type :string
#  loan_question_set_id        :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  loan_response_sets_on_settable                   (loan_question_addable_type,loan_question_addable_id)
#  index_loan_response_sets_on_loan_question_set_id  (loan_question_set_id)
#

FactoryGirl.define do
  factory :loan_response_set do
    loan
    kind 'criteria'
    transient_division
  end
end
