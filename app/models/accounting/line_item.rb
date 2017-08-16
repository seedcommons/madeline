# == Schema Information
#
# Table name: accounting_line_items
#
#  accounting_account_id     :integer
#  accounting_transaction_id :integer
#  amount                    :decimal(, )
#  created_at                :datetime         not null
#  description               :string
#  id                        :integer          not null, primary key
#  posting_type              :string
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
  belongs_to :parent_transaction, class_name: 'Accounting::Transaction'
  belongs_to :accounting_account, class_name: 'Accounting::Account'

  scope :debited_principal, -> (division) {
    debits.where(accounting_account: division.principal_account)
  }

  scope :debited_interest_receivable, -> (division) {
    debits.where(accounting_account: division.interest_receivable_account)
  }

  scope :credited_principal, -> (division) {
    credits.where(accounting_account: division.principal_account)
  }

  scope :credited_interest_receivable, -> (division) {
    credits.where(accounting_account: division.interest_receivable_account)
  }

  def self.debits
    where(posting_type: "debit")
  end

  def self.credits
    where(posting_type: "credit")
  end
end
