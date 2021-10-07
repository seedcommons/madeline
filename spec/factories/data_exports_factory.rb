FactoryBot.define do
  factory :data_export do
    division { root_division }
    name { "Test Data Export" }
    start_date { nil }
    end_date { nil }
    locale_code { "en" }
    data { nil }
    type { DataExport }

    factory :standard_loan_data_export, class: 'StandardLoanDataExport' do
      type { StandardLoanDataExport }
    end

    factory :enhanced_loan_data_export, class: 'EnhancedLoanDataExport' do
      type { EnhancedLoanDataExport }
    end
  end
end
