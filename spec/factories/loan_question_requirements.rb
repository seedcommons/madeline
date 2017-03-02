# == Schema Information
#
# Table name: loan_question_requirements
#
#  amount           :decimal(, )
#  id               :integer          not null, primary key
#  loan_question_id :integer
#  option_id        :integer
#

# Note, functional testing performed within loan_question_spec
FactoryGirl.define do
  factory :loan_question_requirement do
    loan_question
    association :loan_type, factory: :option
  end
end
