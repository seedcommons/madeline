FactoryBot.define do
  factory :data_export do
    division { root_division }
    name { nil }
    start_date { nil }
    end_date { nil }
    locale_code { "en" }
    data { nil }
    type { DataExport }
  end
end
