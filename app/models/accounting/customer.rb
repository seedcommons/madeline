# == Schema Information
#
# Table name: accounting_customers
#
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  qb_id           :string           not null
#  quickbooks_data :json
#  updated_at      :datetime         not null
#

class Accounting::Customer < ApplicationRecord
  QB_OBJECT_TYPE = 'Customer'
  def self.create_or_update_from_qb_object!(qb_object_type:, qb_object:)
    logger.error "Create qb customer: #{qb_object_type}, #{qb_object.as_json}"
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
  def reference
    entity = ::Quickbooks::Model::Entity.new
    entity.type = 'Customer'
    entity_ref = ::Quickbooks::Model::BaseReference.new(self.qb_id)
    entity.entity_ref = entity_ref
    entity
  end
end
