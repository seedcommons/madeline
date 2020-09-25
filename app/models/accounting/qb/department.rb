# == Schema Information
#
# Table name: accounting_qb_departments
#
#  created_at      :datetime         not null
#  division_id     :bigint(8)
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  qb_id           :string           not null
#  quickbooks_data :json
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_accounting_qb_departments_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

# Department in QB = Division in Madeline
#
# Represents a QB Department object and can create a reference object
# for a link to this object in a transaction or other QB object.

class Accounting::QB::Department < ApplicationRecord
  QB_OBJECT_TYPE = 'Department'

  belongs_to :division, optional: true, class_name: "Division"

  def self.create_or_update_from_qb_object!(qb_object_type:, qb_object:)
    department = find_or_initialize_by qb_id: qb_object.id
    department.tap do |d|
      d.update!(
        name: qb_object.name,
        quickbooks_data: qb_object.as_json
      )
    end
  end

  def self.reference(qb_department)
    ::Quickbooks::Model::BaseReference.new(qb_department.qb_id)
  end
end