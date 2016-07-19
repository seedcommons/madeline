# Represents a set a loan questions or division's custom defined fields on a Loan, Person or
# Organization.
#
# Must be instantiated via the CustomFieldSet.resolve method in order to properly merge in
# fields inherited from ancestor divisions.
#
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

  attr_accessor :merged_fields

  def name
    label
  end

  def children
    #custom_fields.where(parent: nil)
    merged_fields.select { |f| f.parent.blank? }
  end

  def child_groups
    children.select { |c| c.data_type == 'group' }
  end

  def depth
    -1
  end

  def depth_first_fields
    list = []
    counter = 0
    merged_fields.where(parent: nil).each do |top_group|
      counter += 1
      top_group.transient_position = counter
      top_group.traverse_depth_first(list)
    end
    list
  end

  # returns a field by ether its id or internal_name
  def field(field_identifier, required: true)
    if field_identifier.is_a?(Integer)
      field = custom_fields.find_by(id: field_identifier)
    else
      field = custom_fields.find_by(internal_name: field_identifier)
    end
    raise "CustomField not found: #{field_identifier} for set: #{internal_name}"  if required && !field
    field
  end


  # Resolve the custom field set matching given internal name defined at the closest ancestor level.
  # future: consider merging field sets at each level of the hierarchy. (not sure if this is useful or desirable)
  def self.resolve(internal_name, division: nil, model: nil, required: true)
    # for model types which are not owned by a division, assume there is only a single CustomFieldSet defined
    # need special handling for Division class to avoid infinite loop
    if !division && (model.class == Division || !model.respond_to?(:division))
      return CustomFieldSet.find_by(internal_name: internal_name)
    end

    division = model.division  if !division && model
    if division
      candidate_division = division
    else
      candidate_division = Division.root
    end

    result = nil
    while candidate_division do
      result = CustomFieldSet.find_by(internal_name: internal_name, division: candidate_division)
      break  if result
      candidate_division = candidate_division.parent
    end

    raise "CustomFieldSet not found: #{internal_name} for division: #{division.try(:id)}"  if required && !result
    result
  end

  # Includes fields defined at parent division levels
  def merged_fields
    @merged_fields ||= resolve_merged_fields
  end

  def resolve_merged_fields
    result = custom_fields
    parent_division = division.parent
    while parent_division do
      match = CustomFieldSet.find_by(internal_name: internal_name, division: parent_division)
      if match
        # Remove fields inherited from a parent division which are overridden at this division level.
        #overridden_ids = result.map(&:overridden_id).compact
        #inheritted_fields = match.custom_fields.reject! { |f| overridden_ids.include?(f.id) }
        #merged_fields += inheritted_fields
        merged_fields += match.custom_fields
      end
      parent_division = parent_division.parent
    end
    result.sort { |left, right| left.position <=> right.position }
    result
  end

end

