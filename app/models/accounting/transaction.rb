# == Schema Information
#
# Table name: accounting_transactions
#
#  accounting_account_id :integer
#  amount                :decimal(, )
#  created_at            :datetime         not null
#  description           :string
#  id                    :integer          not null, primary key
#  private_note          :string
#  project_id            :integer
#  qb_id                 :string           not null
#  qb_transaction_type   :string           not null
#  quickbooks_data       :json
#  total                 :decimal(, )
#  txn_date              :date
#  updated_at            :datetime         not null
#
# Indexes
#
#  acc_trans_qbid_qbtype__unq_idx                          (qb_id,qb_transaction_type) UNIQUE
#  index_accounting_transactions_on_accounting_account_id  (accounting_account_id)
#  index_accounting_transactions_on_project_id             (project_id)
#  index_accounting_transactions_on_qb_id                  (qb_id)
#  index_accounting_transactions_on_qb_transaction_type    (qb_transaction_type)
#
# Foreign Keys
#
#  fk_rails_3b7e4ae807  (accounting_account_id => accounting_accounts.id)
#  fk_rails_662fd2ba2d  (project_id => projects.id)
#

class Accounting::Transaction < ActiveRecord::Base
  QB_TRANSACTION_TYPES = %w(JournalEntry Deposit Purchase).freeze

  belongs_to :account, inverse_of: :transactions, foreign_key: :accounting_account_id
  belongs_to :project, inverse_of: :transactions, foreign_key: :project_id

  def self.find_or_create_from_qb_object(transaction_type:, qb_object:)
    transaction = find_or_initialize_by qb_transaction_type: transaction_type, qb_id: qb_object.id
    transaction.tap do |t|
      t.update_attributes!(quickbooks_data: qb_object.as_json)
    end
  end

  def quickbooks_data
    read_attribute(:quickbooks_data).with_indifferent_access
  end
end
