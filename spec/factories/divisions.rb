FactoryGirl.define do
  factory :division do
    description { Faker::Lorem.sentence }
    name { Faker::Company.name }
    organization
  end
end
