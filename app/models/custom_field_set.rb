# == Schema Information
#
# Table name: custom_field_sets
#
#  created_at    :datetime         not null
#  division_id   :integer
#  id            :integer          not null, primary key
#  internal_name :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_custom_field_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_a3c049608b  (division_id => divisions.id)
#

class CustomFieldSet < ActiveRecord::Base
  include Translatable

  belongs_to :division

  has_many :custom_fields, -> { order(:position) }

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label


  def name
    label
  end


  # returns a field by ether its id or internal_name
  def get_field(field_identifier)
    if field_identifier.is_a?(Integer)
      field = custom_fields.find(field_identifier)
    else
      field = custom_fields.find_by({ internal_name: field_identifier })
    end
    raise "CustomField not found: #{field_identifier} for set: #{internal_name}"  unless field
    field
  end


end
