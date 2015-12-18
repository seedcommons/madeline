FactoryGirl.define do
  factory :cooperative do
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    borough { Faker::Address.city }
    state { Faker::Address.state_abbr }
    contact { Faker::Name.name }
    country { Faker::Address.country }
    industry { Faker::Company.profession }
    name { Faker::Company.name }
    nombre_legal_completo 'Coop'
    recuperada { [0, 1].sample }
  end
end
