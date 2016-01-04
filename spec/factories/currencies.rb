FactoryGirl.define do
  factory :currency do
    code "USD"
    current_exchange_rate 1
    exchange_rate_date { Date.today }
    symbol "US$"
    short_symbol "$"
  end
end
