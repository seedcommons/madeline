# == Schema Information
#
# Table name: accounting_transactions
#
#  created_at          :datetime         not null
#  id                  :integer          not null, primary key
#  qb_transaction_id   :string           not null
#  qb_transaction_type :string           not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  acc_trans_qbid_qbtype__unq_idx                        (qb_transaction_id,qb_transaction_type) UNIQUE
#  index_accounting_transactions_on_qb_transaction_id    (qb_transaction_id)
#  index_accounting_transactions_on_qb_transaction_type  (qb_transaction_type)
#

class Accounting::Transaction < ActiveRecord::Base
  attr_writer :qb_object

  delegate :txn_date, :total, :private_note, to: :qb_object

  # Make sure to append this after the last link in the relation chain. It will ensure
  # the quickbooks data is populated.
  def self.with_qb_objects
    transactions = all
    return transactions if transactions.count < 1

    Accounting::Quickbooks::Fetcher.new(transactions).fetch
  end

  def qb_object
    raise ArgumentError, 'qb_object not already set. Make sure to append #with_qb_objects at the end of an AR chain.' if @qb_object.blank?
    @qb_object
  end
end
