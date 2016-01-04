FactoryGirl.define do
  factory :organization do
    display_name { Faker::Company.name }
    sector { Faker::Company.profession }
    industry { Faker::Company.profession }
    woman_ownership_percent { rand(1..100) }
    poc_ownership_percent { rand(1..100) }
    environmental_impact_score { rand(1..100) }
  end
end
