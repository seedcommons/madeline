# == Schema Information
#
# Table name: accounting_qb_vendors
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  quickbooks_data :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  qb_id           :string           not null
#
FactoryBot.define do
  factory :accounting_qb_vendor, class: 'Accounting::QB::Vendor', aliases: [:vendor] do
    sequence(:qb_id)
    sequence(:name) { |n| "Vendor #{n}" }
  end
end
