# == Schema Information
#
# Table name: accounting_line_items
#
#  accounting_account_id     :integer          not null
#  accounting_transaction_id :integer          not null
#  amount                    :decimal(, )      not null
#  created_at                :datetime         not null
#  description               :string
#  id                        :integer          not null, primary key
#  posting_type              :string           not null
#  qb_line_id                :integer
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_accounting_line_items_on_accounting_account_id      (accounting_account_id)
#  index_accounting_line_items_on_accounting_transaction_id  (accounting_transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (accounting_account_id => accounting_accounts.id)
#  fk_rails_...  (accounting_transaction_id => accounting_transactions.id)
#

FactoryBot.define do
  factory :accounting_line_item, class: 'Accounting::LineItem', aliases: [:line_item] do
    qb_line_id { 1 }
    association :parent_transaction, factory: :accounting_transaction
    association :account
    posting_type { ["credit", "debit"].sample }
    description { Faker::Hipster.sentence(4).chomp(".") }
    amount { Faker::Number.decimal(4, 2) }
  end
end
