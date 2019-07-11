FactoryBot.define do
  factory :data_export do
    name { "MyString" }
    start_date { "2019-07-05" }
    end_date { "2019-07-05" }
    locale_code { "MyString" }
    custom_data { "" }
    type { "" }
  end
end
