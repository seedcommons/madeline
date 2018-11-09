# == Schema Information
#
# Table name: loan_question_requirements
#
#  amount      :decimal(, )
#  id          :integer          not null, primary key
#  option_id   :integer
#  question_id :integer
#

# Note, functional testing performed within loan_question_spec
FactoryBot.define do
  factory :loan_question_requirement do
    question
    association :loan_type, factory: :option
  end
end
