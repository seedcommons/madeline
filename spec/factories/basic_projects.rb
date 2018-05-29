FactoryBot.define do
  factory :basic_project do
    division { root_division }
    name {"Test Basic Project"}
    association :primary_agent_id, factory: :person
    association :secondary_agent_id, factory: :person
    status_value { ["active", "completed", "changed", "possible"].sample }
    public_level_value "featured"

    trait :with_translations do
      after(:create) do |project|
        create(:translation, translatable: project, translatable_attribute: :summary)
        create(:translation, translatable: project, translatable_attribute: :details)
      end
    end

    trait :with_foreign_translations do
      after(:create) do |project|
        create(:translation,
          translatable: project, translatable_attribute: :summary, locale: :es, text: Faker::Lorem.paragraph(2))
        create(:translation,
          translatable: project, translatable_attribute: :details, locale: :es, text: Faker::Lorem.paragraph(2))
      end
    end
  end
end
