FactoryGirl.define do
  factory :country do
    iso_code { Faker::Address.country_code }
    currency
  end
end
