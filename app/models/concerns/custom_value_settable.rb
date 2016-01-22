#
# Encapsulates associating a schema of custom fields to a model type and getting/setting values stored into a
# JSON field on the model instance.
# Assumes that a JSON db column named 'custom_data' exists.  (future: allow this to be customized)
#
# Represents a loan questionnaire set of response data
# May also be used in the future store store custom values which are logical extensions of a core model type
#


module CustomValueSettable
  extend ActiveSupport::Concern


  module ClassMethods

    # Define convenience methods to access associated CustomValueSet instances by a CustomFieldSet name
    # def attr_custom_value_settable(*custom_field_set_names)
    #   logger.info "custom_field_set_names: #{custom_field_set_names.inspect}"
    #   custom_field_set_names.each do |name|
    #     define_method(name) { custom_value_set(name) }
    #   end
    # end

    def custom_field_set
      # Treats the custom field set with a name matching the model name defines the custom fields directly
      # included on the model instance.
      field_set = CustomFieldSet.find_by(internal_name: self.name)
      raise "CustomFieldSet not found: #{self.name}"  unless field_set
      field_set
    end

    def get_field(field_identifier)
      custom_field_set.get_field(field_identifier)
    end

    # Filter against a custom value
    # Optionally specify a base relation to chain from.
    # future: expand our filter API as needs are more clear
    def where_custom_value(field_identifier, value, base_relation=nil)
      base_relation ||= self
      field = get_field(field_identifier)
      base_relation.where("custom_data->>? = ?", field.json_key, value)
    end

  end

  # find or create the value set instance associated with given field set name for this model instance
  def custom_value_set(field_set_name)
    field_set = CustomFieldSet.find_by(internal_name: field_set_name)
    raise "CustomFieldSet not found: #{field_set_name}"  unless field_set
    custom_value_sets.find_or_create_by(custom_value_settable: self, custom_field_set: field_set)
  end



  def ensured_custom_data
    custom_data || {}
  end

  def update_value(field_identifier, value)
    field = get_field(field_identifier)  # note, this is fatal if field not found
    data = ensured_custom_data
    # future: value manipulation depending on field data type
    data[field.json_key] = value
    self.update(custom_data: data)
  end

  def get_value(field_identifier)
    field = get_field(field_identifier)
    result = ensured_custom_data[field.json_key]
    # future: result manipulation depending on field data type
  end

  def get_field(field_identifier)
    self.class.get_field(field_identifier)
  end


end


