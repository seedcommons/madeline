FactoryBot.define do
  factory :note do
    association :notable, factory: :organization
    association :author, factory: :person
    transient_division

    # for now parent must be saved before assigning the text
    # beware, this currently depends on a Language instance having already been created as a side-effect from other associations
    after(:create) do |note|
      note.set_text(Faker::Lorem.sentence)
    end
  end
end
