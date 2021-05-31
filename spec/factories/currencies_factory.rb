FactoryBot.define do
  factory :currency do
    name { "U.S. Dollar" }
    code { "USD" }
    symbol { "US$" }
    short_symbol { "$" }
    country_code { "US" }
  end
end
