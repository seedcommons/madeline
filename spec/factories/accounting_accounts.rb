# == Schema Information
#
# Table name: accounting_accounts
#
#  created_at                :datetime         not null
#  id                        :integer          not null, primary key
#  name                      :string           not null
#  qb_account_classification :string
#  qb_id                     :string           not null
#  quickbooks_data           :json
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_accounting_accounts_on_qb_id  (qb_id)
#

FactoryBot.define do
  factory :accounting_account, class: 'Accounting::Account', aliases: [:account] do
    sequence(:qb_id)
    sequence(:name) { |n| "Account #{n}" }
    qb_account_classification 'Asset'
  end
end
