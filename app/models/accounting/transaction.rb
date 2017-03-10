# == Schema Information
#
# Table name: accounting_transactions
#
#  accounting_account_id :integer
#  created_at            :datetime         not null
#  id                    :integer          not null, primary key
#  project_id            :integer
#  qb_id                 :string           not null
#  qb_transaction_type   :string           not null
#  quickbooks_data       :json
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
  TRANSACTION_TYPES = %w(JournalEntry Deposit Purchase).freeze

  attr_writer :qb_object

  belongs_to :account, inverse_of: :transactions, foreign_key: :accounting_account_id

  delegate :txn_date, :total, :private_note, to: :qb_object

  # # We need to override where to ensure the qb_object data gets populated when queried.
  # def self.where(*args)
  #
  #   puts '=' * 50
  #   puts 'hello from where'
  #   puts '=' * 50
  #
  #
  #
  #   transactions = super(*args)
  #   return transactions if transactions.count < 1
  #
  #   Accounting::Quickbooks::Fetcher.new(transactions).fetch
  # end
  #
  # # We need to override where to ensure the qb_object data gets populated when queried.
  # def self.all
  #   transactions = super
  #   return transactions if transactions.count < 1
  #
  #   Accounting::Quickbooks::Fetcher.new(transactions).fetch
  # end

  def self.with_qb_objs
    transactions = all
    return transactions if transactions.count < 1

    Accounting::Quickbooks::Fetcher.new(transactions).fetch
  end

  def qb_object
    raise ArgumentError, 'qb_object not already set. Make sure to append #with_qb_objects at the end of an AR chain.' if @qb_object.blank?
    @qb_object
  end
end
