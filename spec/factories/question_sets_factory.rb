FactoryBot.define do
  factory :question_set do
    kind { QuestionSet::KINDS.sample }
    division { root_division }

    trait :with_questions do
      kind { 'loan_criteria' }
      after(:create) do |model|
        create(:question, division: model.division, parent: model.root_group, question_set: model, data_type: 'number')
        create(:question, division: model.division, parent: model.root_group, question_set: model, data_type: 'text')
      end
    end
  end
end
