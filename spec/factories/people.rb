FactoryGirl.define do
  factory :person do
    division
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    association :primary_organization, factory: :organization
    birth_date { Faker::Date.between(100.years.ago, 18.years.ago) }
  end
end
