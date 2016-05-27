# == Schema Information
#
# Table name: custom_fields
#
#  created_at          :datetime         not null
#  custom_field_set_id :integer
#  data_type           :string
#  id                  :integer          not null, primary key
#  internal_name       :string
#  label               :string
#  parent_id           :integer
#  position            :integer
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_custom_fields_on_custom_field_set_id  (custom_field_set_id)
#
# Foreign Keys
#
#  fk_rails_b30226ad05  (custom_field_set_id => custom_field_sets.id)
#

class CustomField < ActiveRecord::Base
  include Translatable

  belongs_to :custom_field_set
  # note, the custom field form layout can be hierarchially nested

  has_closure_tree order: 'position'

  # Transient value populated by depth first traversal of questions scoped to a specific division.
  # Starts with '1'.  Used in hierarchical display of questions.
  attr_accessor :transient_position

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label

  delegate :division, :division=, to: :custom_field_set


  def name
    "#{custom_field_set.internal_name}-#{internal_name}"
  end

  def traverse_depth_first(list)
    list << self
    counter = 0
    children.each do |child|
      counter += 1
      child.transient_position = counter
      child.traverse_depth_first(list)
    end
  end

  # for now use a stringified primary key
  # todo: consider using the internal name when available - needs further discussion
  def json_key
    id.to_s
  end

  def translatable?
    data_type == 'translatable'
  end

  DATA_TYPES = ['string', 'text', 'number', 'range', 'group', 'boolean', 'translatable', 'list']


end
