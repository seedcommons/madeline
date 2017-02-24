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
    raise 'qb_object not already set' if @qb_object.blank?
    @qb_object
  end

  def self.qb_where(**args)
    transactions = where(args)
    return transactions if transactions.count < 1

    Accounting::Quickbooks::Fetcher.new(transactions).fetch
  end

  def self.qb_all
    transactions = all
    return transactions if transactions.count < 1

    Accounting::Quickbooks::Fetcher.new(transactions).fetch
  end
end
