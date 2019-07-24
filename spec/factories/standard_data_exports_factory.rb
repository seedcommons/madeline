FactoryBot.define do
  factory :standard_data_export do
    name { "My Standard Data Export" }
    start_date { "2019-07-05" }
    end_date { "2019-07-05" }
    locale_code { "en" }
    custom_data { nil }
  end
end
