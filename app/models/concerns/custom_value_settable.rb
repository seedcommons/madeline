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
    def resolve_custom_field_set(division: nil, model: nil, required: true)
      CustomFieldSet.resolve(self.name, division: division, model: model, required: required)
    end


    # Filter against a custom value
    # Optionally specify a base relation to chain from.
    # future: expand our filter API as needs are more clear
    def where_custom_value(field_identifier, value, base_relation: nil, division: nil)
      base_relation ||= self
      field = resolve_custom_field_set(division: division).field(field_identifier)
      base_relation.where("custom_data->>? = ?", field.json_key, value)
    end

    def custom_field?(field_identifier, division: nil, model: nil)
      field_set = resolve_custom_field_set(division: division, model: model, required: true)
      field_set && field_set.field(field_identifier, required: false).present?
    end

  end


  def ensured_custom_data
    self.custom_data ||= {}
    self.custom_data  # this explicit return value is important!
  end

  def update_custom_value(field_identifier, value)
    data = set_custom_value(field_identifier, value)
    self.update(custom_data: data)
  end

  def set_custom_value(field_identifier, value)
    field = custom_field(field_identifier)  # note, this is fatal if field not found
    data = ensured_custom_data
    # future: value manipulation depending on field data type
    data[field.json_key] = value
    data
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

  def custom_field?(field_identifier)
    self.class.custom_field?(field_identifier, model: self)
  end

  def method_missing(method_sym, *arguments, &block)
    attribute_name, action = match_dynamic_method(method_sym)
    puts("mm attr name: #{attribute_name}, action: #{action}, args.first: #{arguments.first}")
    if action
      case action
        when :get
          custom_value(attribute_name)
        when :set
          set_custom_value(attribute_name, arguments.first)
        when :update
          update_custom_value(attribute_name, arguments.first)
      end
    else
      super
    end
  end

  def respond_to_missing?(method_sym, include_private = false)
    attribute_name, action = match_dynamic_method(method_sym)
    if action
      true
    else
      super
    end
  end

  def match_dynamic_method(method_sym)
    method_name = method_sym.to_s
    if method_name.ends_with?('=')
      attribute_name = method_name.chomp('=')
      action = :set
    elsif method_name.starts_with?('update_')
      attribute_name = method_name.sub('update_', '')
      action = :update
    else
      attribute_name = method_name
      action = :get
    end

    if custom_field?(attribute_name)
      [attribute_name, action]
    else
      [nil,nil]
    end
  end


end


