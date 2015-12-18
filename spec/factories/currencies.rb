FactoryGirl.define do
  factory :currency do
    country 'United States'
    default_currency 1
    description { "The currency of #{country}" }
    symbol 'US$'
    exchange_rate 1
  end
end
