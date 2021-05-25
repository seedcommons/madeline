# Represents an account as in a typical double-entry accounting system.
# Accounts defined in the associated Quickbooks instance are synced and cached locally on Madeline.
# Quickbooks should be considered the authoritative source for account information.
class Accounting::Account < ApplicationRecord
  QB_OBJECT_TYPE = 'Account'
  belongs_to :project

  has_many :transactions, inverse_of: :account, foreign_key: :accounting_account_id, dependent: :destroy
  has_many :line_items, inverse_of: :account, foreign_key: :accounting_account_id, dependent: :destroy

  # Eventually this should be incorporated into the DataExtractor class hierarchy
  def self.create_or_update_from_qb_object!(qb_object_type:, qb_object:)
    account = find_or_initialize_by qb_id: qb_object.id
    account.tap do |a|
      a.update_attributes!(
        name: qb_object.name,
        qb_account_classification: qb_object.classification,
        quickbooks_data: qb_object.as_json
      )
    end
  end

  def self.asset_accounts
    where(qb_account_classification: 'Asset').order(:name)
  end

  # The quickbooks-ruby gem's helper account_id does not seem
  # to work for creating check txns.
  def reference
    entity_ref = ::Quickbooks::Model::BaseReference.new(self.qb_id)
    entity_ref.type = Accounting::Account::QB_OBJECT_TYPE
    entity_ref.name = self.name
    entity_ref
  end
end
