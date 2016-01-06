FactoryGirl.define do
  factory :organization do
    division
    name { Faker::Company.name }
    sector { Faker::Company.profession }
    industry { Faker::Company.profession }
  end
end
