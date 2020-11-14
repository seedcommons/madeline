# == Schema Information
#
# Table name: accounting_customers
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  quickbooks_data :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  qb_id           :string           not null
#
FactoryBot.define do
  factory :accounting_customer, class: 'Accounting::Customer', aliases: [:customer] do
    sequence(:qb_id)
    sequence(:name) { |n| "Customer #{n}" }
  end
end
