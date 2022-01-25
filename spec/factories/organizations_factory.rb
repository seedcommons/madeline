FactoryBot.define do
  factory :organization do
    division { root_division }
    country
    city { Faker::Address.city }
    name { Faker::Company.name }
    sector { Faker::Company.profession }
    industry { Faker::Company.profession }
    postal_code { Faker::Address.postcode }
    state { Faker::Address.state }
    entity_structure { "llc" }
  end
end
