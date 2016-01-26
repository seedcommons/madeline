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
  def field(field_identifier)
    if field_identifier.is_a?(Integer)
      field = custom_fields.find(field_identifier)
    else
      field = custom_fields.find_by({ internal_name: field_identifier })
    end
    raise "CustomField not found: #{field_identifier} for set: #{internal_name}"  unless field
    field
  end


  # Resolve the custom field set matching given internal name defined at the closest ancestor level.
  # future: consider merging field sets at each level of the hierarchy. (not sure if this is useful or desirable)
  def self.resolve(internal_name, division: nil, model: nil)
    division = model.division  if !division && model
    if division
      # puts "CustomFieldSet.resolve - using division param"
      candidate_division = division
    else
      # puts "CustomFieldSet.resolve - using Division.root default"
      candidate_division = Division.root
    end

    result = nil
    # todo: confirm if there is a clever way to leverage closure tree to handle this hierarchical resolve logic
    while candidate_division do
      result = CustomFieldSet.find_by(internal_name: internal_name, division: candidate_division)
      break  if result
      candidate_division = candidate_division.parent
    end

    raise "CustomFieldSet not found: #{self.name} for division: #{division.try(:id)}"  unless result
    result
  end

end

