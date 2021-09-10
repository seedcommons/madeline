FactoryBot.define do
  factory :question_set do
    kind { QuestionSet::KINDS.sample }
    division { root_division }

    trait :with_questions do
      kind { 'loan_criteria' }
      after(:create) do |model|
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'summary', data_type: 'text')
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'workers', data_type: 'number')
      end
    end
  end
end
