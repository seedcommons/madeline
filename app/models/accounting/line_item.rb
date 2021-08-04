# Stores per-account details for a particular transaction as per typical double-entry accounting.
# Tracks a corresponding line item in Quickbooks. Note however that Quickbooks does not assign
# unique IDs to line items as it does to transactions and accounts. Instead it assigns sequential "line IDs",
# which we do store.
# Quickbooks should be considered the authoritative source for line item information.
class Accounting::LineItem < ApplicationRecord
  belongs_to :parent_transaction, class_name: 'Accounting::Transaction', foreign_key: :accounting_transaction_id
  belongs_to :account, class_name: 'Accounting::Account', foreign_key: :accounting_account_id

  def credit?
    posting_type == "Credit".freeze
  end

  def debit?
    posting_type == "Debit".freeze
  end

  def type_or_amt_changed?
    (changes.keys & %w(posting_type amount).freeze).any?
  end
end
