# == Schema Information
#
# Table name: accounting_line_items
#
#  accounting_account_id     :integer          not null
#  accounting_transaction_id :integer
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
#  fk_rails_c0f205ff31  (accounting_account_id => accounting_accounts.id)
#  fk_rails_c987f5b811  (accounting_transaction_id => accounting_transactions.id)
#

class Accounting::LineItem < ActiveRecord::Base
  belongs_to :parent_transaction, class_name: 'Accounting::Transaction', foreign_key: :accounting_transaction_id
  belongs_to :account, class_name: 'Accounting::Account', foreign_key: :accounting_account_id

  def credit?
    posting_type == "credit"
  end

  def debit?
    posting_type == "debit"
  end
end
