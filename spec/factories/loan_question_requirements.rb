# Note, functional testing performed within loan_question_spec
FactoryGirl.define do
  factory :loan_question_requirement do
    loan_question
    association :loan_type, factory: :option
  end
end
