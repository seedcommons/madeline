# == Schema Information
#
# Table name: data_exports
#
#  id          :bigint           not null, primary key
#  data        :json
#  end_date    :datetime
#  locale_code :string           not null
#  name        :string           not null
#  start_date  :datetime
#  type        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  division_id :bigint           not null
#
# Indexes
#
#  index_data_exports_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#
FactoryBot.define do
  factory :data_export do
    division { root_division }
    name { "Test Data Export" }
    start_date { nil }
    end_date { nil }
    locale_code { "en" }
    data { nil }
    type { DataExport }
  end

  factory :standard_loan_data_export, parent: :data_export, class: 'StandardLoanDataExport' do
    type { StandardLoanDataExport }
  end
end
