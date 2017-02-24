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

class Accounting::Transaction < ActiveRecord::Base
  attr_writer :qb_object

  delegate :txn_date, :total, :private_note, to: :qb_object

  def qb_object
    raise ArgumentError, 'qb_object not already set. Use where or all to have it populated for you.' if @qb_object.blank?
    @qb_object
  end

  # We need to override where to ensure the qb_object data gets populated when queried.
  def self.where(**args)
    transactions = super(args)
    return transactions if transactions.count < 1

    Accounting::Quickbooks::Fetcher.new(transactions).fetch
  end

  # We need to override where to ensure the qb_object data gets populated when queried.
  def self.all
    transactions = super
    return transactions if transactions.count < 1

    Accounting::Quickbooks::Fetcher.new(transactions).fetch
  end
end
