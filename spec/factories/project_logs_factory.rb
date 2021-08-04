FactoryBot.define do
  factory :project_log do
    project_step
    association :agent, factory: :person
    date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    progress_metric_value { ["behind", "on_time", "ahead"].sample }
    transient_division

    # for now parent must be saved before assigning the translatable fields
    after(:create) do |log|
      log.set_summary(Faker::Lorem.sentences(3))
      log.set_details(Faker::Lorem.paragraphs(3))
      log.set_additional_notes(Faker::Lorem.sentences(3))
      log.set_private_notes(Faker::Lorem.paragraph)
    end

    trait :old do
      date { Faker::Date.between(60.days.ago, 30.days.ago) }
    end

    trait :recent do
      date { Faker::Date.between(5.days.ago, 1.day.ago) }
    end

  end
end
