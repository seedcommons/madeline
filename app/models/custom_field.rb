# == Schema Information
#
# Table name: custom_fields
#
#  created_at          :datetime         not null
#  custom_field_set_id :integer
#  data_type           :string
#  id                  :integer          not null, primary key
#  internal_name       :string
#  migration_position  :integer
#  parent_id           :integer
#  position            :integer
#  required            :boolean          default(FALSE), not null
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
  has_closure_tree order: 'position', dependent: :destroy

  # Transient value populated by depth first traversal of questions scoped to a specific division.
  # Starts with '1'.  Used in hierarchical display of questions.
  attr_accessor :transient_position

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label
  attr_translatable :explanation

  delegate :division, :division=, to: :custom_field_set

  validates :data_type, presence: true

  after_save :ensure_internal_name

  DATA_TYPES = %i(string text number range group boolean translatable list)

  def name
    "#{custom_field_set.internal_name}-#{internal_name}"
  end

  def attribute_sym
    internal_name.to_sym
  end

  # List of value keys for fields which have nested values
  def value_types
    result =
      case data_type
      when 'string'
        [:text]
      when 'text'
        [:text]
      when 'number'
        [:number]
      when 'range'
        [:rating, :text]
      else
        []
      end

    if has_embeddable_media
      if result
        result << :embeddable_media
      else
        raise "has_embeddable_media flag enabled for unexpected data_type: #{data_type}"
      end
    end
    result
  end

  # Simple form type mapping
  def form_field_type
    case data_type
    when 'string'
      :string
    when 'text'
      :text
    when 'number'
      :decimal
    when 'range'
      :select
    when 'boolean'
      :boolean
    when 'translatable'
      :text
    when 'list'
      :select
    when 'group'
      nil # group type fields are not expected to have rendered form fields
    end
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

  private

    def ensure_internal_name
      if !internal_name
        self.update! internal_name: "field_#{id}"
      end
    end
end
