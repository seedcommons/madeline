FactoryGirl.define do
  factory :country do
    iso_code { Faker::Address.country_code }
    association :default_language, factory: :language
    association :default_currency, factory: :currency
  end
end
