# == Schema Information
#
# Table name: custom_models
#
#  created_at                 :datetime         not null
#  custom_data                :json
#  custom_field_set_id        :integer          not null
#  custom_model_linkable_id   :integer          not null
#  custom_model_linkable_type :string           not null
#  id                         :integer          not null, primary key
#  updated_at                 :datetime         not null
#
# Indexes
#
#  custom_models_on_linkable                   (custom_model_linkable_type,custom_model_linkable_id)
#  index_custom_models_on_custom_field_set_id  (custom_field_set_id)
#
# Foreign Keys
#
#  fk_rails_99a00e528f  (custom_field_set_id => custom_field_sets.id)
#

# Represents a dynamic model instance which can be owned in a one-to-many 'belongs_to' relation by another
# model instance in the system.
# Primary use case are a Loan's Criteria and Loan Post-analysis questionnaires.
# Actual values are stored into a JSON field keyed by the numeric id of the associated field.
# Note, the current design allows for custom field definitions to optionally specificy a 'slug' style field name,
# but does not require it.  The custom value can be resolved either by field id, or the field 'internal_name' if assigned
#
# todo: discuss renaming this 'CustomModel'

class CustomModel < ActiveRecord::Base
  include CustomValueSettable


  belongs_to :custom_model_linkable, polymorphic: true
  belongs_to :custom_field_set


  def ensured_custom_data
    custom_data || {}
  end

  def update_value(field_identifier, value)
    field = get_field(field_identifier)  # note, this is fatal if field not found
    data = ensured_custom_data
    # todo: value manipulation depending on field data type
    data[field.json_key] = value
    self.update(custom_data: data)
  end

  def get_value(field_identifier)
    field = get_field(field_identifier)
    result = ensured_custom_data[field.json_key]
    # todo: result manipulation depending on field data type
  end

  def get_field(field_identifier)
    custom_field_set.get_field(field_identifier)
  end


  #UNUSED - implementation version using a separate table for the custom values
  # has_many :custom_values
  #
  # def set_value(field_identifier, value)
  #   field = get_field(field_identifier)
  #   custom = custom_values.find_or_create_by(custom_value_set: self, custom_field: field)
  #   custom.update(value: value)
  # end
  #
  # def get_value(field_identifier)
  #   field = get_field(field_identifier)
  #   custom = custom_values.find_by(custom_value_set: self, custom_field: field)
  #   custom && custom.value
  # end

end
