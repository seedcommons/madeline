#
# Encapsulates associating a schema of custom fields to a model type and getting/setting values stored into a
# JSON field on the model instance.
# Assumes that a JSON db column named 'custom_data' exists.  (future: allow this column name to be customized)
#


module CustomValueSettable
  extend ActiveSupport::Concern

  module ClassMethods

    # Resolve the custom field set matching our model type defined at the closest ancestor level.
    # Note, this is overridden for CustomModel which has it's field set explicitly assigned based on the link context
    def resolve_custom_field_set(division: nil, model: nil)
      CustomFieldSet.resolve(self.name, division: division, model: model)
    end


    # Filter against a custom value
    # Optionally specify a base relation to chain from.
    # future: expand our filter API as needs are more clear
    def where_custom_value(field_identifier, value, base_relation: nil, division: nil)
      base_relation ||= self
      field = resolve_custom_field_set(division: division).field(field_identifier)
      base_relation.where("custom_data->>? = ?", field.json_key, value)
    end

  end


  def ensured_custom_data
    custom_data || {}
  end

  def update_custom_value(field_identifier, value)
    field = custom_field(field_identifier)  # note, this is fatal if field not found
    data = ensured_custom_data
    # future: value manipulation depending on field data type
    data[field.json_key] = value
    self.update(custom_data: data)
  end

  def custom_value(field_identifier)
    field = custom_field(field_identifier)
    result = ensured_custom_data[field.json_key]
    # future: result manipulation depending on field data type
  end

  def resolve_custom_field_set
    self.class.resolve_custom_field_set(model: self)
  end

  def custom_field(field_identifier)
    resolve_custom_field_set.field(field_identifier)
  end


end


