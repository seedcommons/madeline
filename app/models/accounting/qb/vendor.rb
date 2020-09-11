# == Schema Information
#
# Table name: accounting_qb_vendors
#
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  qb_id           :string           not null
#  quickbooks_data :json
#  updated_at      :datetime         not null
#

class Accounting::QB::Vendor < ApplicationRecord
  has_many :transactions, inverse_of: :vendor, foreign_key: :qb_vendor_id, dependent: :nullify
  QB_OBJECT_TYPE = 'Vendor'
  def self.create_or_update_from_qb_object!(qb_object_type:, qb_object:)
    vendor = find_or_initialize_by qb_id: qb_object.id
    vendor.tap do |v|
      v.update!(
        name: qb_object.display_name,
        quickbooks_data: qb_object.as_json
      )
    end
  end

  # The quickbooks-ruby gem does not implement a helper method for _id like account or class,
  # and in qb api line items need entity, not vendor_id.
  def reference
    entity_ref = ::Quickbooks::Model::BaseReference.new(self.qb_id)
    entity_ref.type = Accounting::QB::Vendor::QB_OBJECT_TYPE
    entity_ref.name = self.name
    entity_ref
  end
end
