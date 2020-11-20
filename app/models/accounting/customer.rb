# == Schema Information
#
# Table name: accounting_customers
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  quickbooks_data :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  qb_id           :string           not null
#

class Accounting::Customer < ApplicationRecord
  has_many :transactions, inverse_of: :customer, foreign_key: :accounting_customer_id, dependent: :nullify
  QB_OBJECT_TYPE = 'Customer'
  def self.create_or_update_from_qb_object!(qb_object_type:, qb_object:)
    customer = find_or_initialize_by qb_id: qb_object.id
    customer.tap do |c|
      c.update!(
        name: qb_object.display_name,
        quickbooks_data: qb_object.as_json
      )
    end
  end

  # The quickbooks-ruby gem does not implement a helper method for _id like account or class,
  # and in qb api line items need entity, not customer_id.
  def entity
    entity = ::Quickbooks::Model::Entity.new
    entity.type = Accounting::Customer::QB_OBJECT_TYPE
    entity_ref = ::Quickbooks::Model::BaseReference.new(self.qb_id)
    entity.entity_ref = entity_ref
    entity
  end

  def reference
    entity_ref = ::Quickbooks::Model::BaseReference.new(self.qb_id)
    entity_ref.type = Accounting::Customer::QB_OBJECT_TYPE
    entity_ref.name = self.name
    entity_ref
  end
end
