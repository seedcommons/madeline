FactoryGirl.define do
  factory :timeline_entry do
    association :project, factory: :loan
    association :agent, factory: :person
    scheduled_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    is_finalized [true, false].sample
    step_type_value { ["step", "milestone"] }
    transient_division
    summary { Faker::Hipster.paragraph }
    details { Faker::Hipster.paragraphs }
  end
end
