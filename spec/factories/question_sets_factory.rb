FactoryBot.define do
  factory :question_set do
    internal_name { QuestionSet::KINDS.sample }
    division { root_division }

    trait :generic_fields do
      after(:create) do |model|
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'a_string', data_type: 'string')
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'a_number', data_type: 'number')
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'a_boolean', data_type: 'boolean')
      end
    end

    trait :loan_criteria do
      internal_name { 'loan_criteria' }
      after(:create) do |model|
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'summary', data_type: 'text')
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'workers', data_type: 'number')
      end
    end

    trait :loan_post_analysis do
      internal_name { 'loan_post_analysis' }
      after(:create) do |model|
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'new_worker_knowledge', data_type: 'text')
        create(:question, parent: model.root_group, question_set: model,
          internal_name: 'total_loan_amount', data_type: 'number')
      end
    end
  end
end
