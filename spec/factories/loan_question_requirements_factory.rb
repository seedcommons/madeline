# Note, functional testing performed within loan_question_spec
FactoryBot.define do
  factory :loan_question_requirement do
    question
    association :loan_type, factory: :option
  end
end
