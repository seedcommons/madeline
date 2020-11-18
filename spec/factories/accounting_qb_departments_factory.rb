# == Schema Information
#
# Table name: accounting_qb_departments
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  quickbooks_data :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  division_id     :bigint
#  qb_id           :string           not null
#
# Indexes
#
#  index_accounting_qb_departments_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#
FactoryBot.define do
  factory :accounting_qb_department, class: 'Accounting::QB::Department', aliases: [:department] do
    sequence(:qb_id)
    sequence(:name) { |n| "Department #{n}" }
  end
end
