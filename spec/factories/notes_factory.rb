FactoryBot.define do
  factory :note do
    transient do
      text { Faker::Lorem.sentence }
    end

    association :notable, factory: :organization
    association :author, factory: :person
    transient_division

    after(:create) do |note, evaluator|
      note.update!(text_en: evaluator.text)
    end
  end
end
