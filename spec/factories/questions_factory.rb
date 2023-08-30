FactoryBot.define do
  factory :question do
    transient do
      label { Faker::Lorem.words(2).join(' ') }
    end

    division { root_division }
    question_set
    data_type { Question::DATA_TYPES.sample }
    active { true }
    internal_name { "#{Faker::Name.unique.name}_field" }

    after(:build) do |model|
      model.parent ||= model.question_set.root_group
    end

    after(:create) do |model, evaluator|
      model.update!(label_en: evaluator.label)
    end

    trait :with_url do
      has_embeddable_media { true }
    end
  end
end
