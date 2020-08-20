# == Schema Information
#
# Table name: accounting_qb_departments
#
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  qb_id           :string           not null
#  quickbooks_data :json
#  updated_at      :datetime         not null
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
end
