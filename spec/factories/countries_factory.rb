FactoryBot.define do
  factory :country do
    iso_code { Faker::Address.country_code }
    name { Faker::Address.country }
    default_currency { Currency.all.sample || create(:currency) }

    # compatibility with policy specs
    transient do
      division { nil }
    end
  end
end
