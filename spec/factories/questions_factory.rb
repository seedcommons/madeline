FactoryBot.define do
  factory :question do
    division { root_division }
    question_set
    internal_name { Faker::Lorem.words(2).join('_').downcase }
    data_type { Question::DATA_TYPES.sample }
    active { true }

    after(:build) do |model|
      model.parent ||= model.question_set.root_group
    end

    after(:create) do |model|
      model.set_label(Faker::Lorem.words(2).join(' '))
    end
  end
end
