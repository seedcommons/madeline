#
# Encapsulates associating a schema of custom fields to a model type and getting/setting values stored into a
# JSON field on the model instance.
# Assumes that a JSON db column named 'custom_data' exists.  (future: allow this column name to be customized)
#


module CustomFieldAddable
  extend ActiveSupport::Concern

  # todo: confirm if there are any negative consequences of potential duplicate includes of the Translatable module
  include Translatable

  module ClassMethods

    # Resolve the custom field set matching our model type defined at the closest ancestor level.
    # Note, this is overridden for CustomValueSet which has it's field set explicitly assigned based on the link context
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
      field_set = resolve_custom_field_set(division: division, model: model, required: false)
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
    if field.translatable?
      set_translation(field.json_key, value)
    else
      data = ensured_custom_data
      # future: value manipulation depending on field data type
      data[field.json_key] = value
      data
    end
  end


  def custom_value(field_identifier)
    field = custom_field(field_identifier)
    result = ensured_custom_data[field.json_key]
    # future: result manipulation depending on field data type
  end

  # todo: consider making 'required: false' the default
  def resolve_custom_field_set(required: true)
    self.class.resolve_custom_field_set(model: self, required: required)
  end

  def custom_field(field_identifier, required: true)
    field_set = resolve_custom_field_set(required: required)
    field_set.field(field_identifier, required: required)  if field_set
  end

  def custom_field?(field_identifier)
    self.class.custom_field?(field_identifier, model: self)
  end

  def method_missing(method_sym, *arguments, &block)
    attribute_name, action, field = match_dynamic_method(method_sym)
    # puts("mm attr name: #{attribute_name}, action: #{action}, args.first: #{arguments.first}")
    if action
      case action
        when :get
          if field.translatable?
            # beware, this is now returning the Translation, not the text value
            return get_translation(field.json_key)
          else
            return custom_value(attribute_name)
          end
        when :set
          return set_custom_value(attribute_name, arguments.first)
        when :update
          return update_custom_value(attribute_name, arguments.first)
        when :get_list
          puts "get list translatable - json key: #{field.json_key}"
          if field.translatable?
            return get_translations(field.json_key)
          end
        when :set_list
          puts "set list translatable - json key: #{field.json_key}"
          if field.translatable?
            return set_translations(field.json_key, arguments.first)
          end
      end
    end
    super
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
    # elsif method_name.ends_with?('_list')
    #   # translatable support
    #   attribute_name = method_name.chomp('_list')
    #   if attribute_name.starts_with?('set_')
    #     attribute_name = attribute_name.sub('set_', '')
    #     action = :set_list
    #   else
    #     action = :get_list
    #   end
    elsif method_name.ends_with?('_translations')
      # translatable support
      attribute_name = method_name.chomp('_translations')
      if attribute_name.starts_with?('set_')
        attribute_name = attribute_name.sub('set_', '')
        action = :set_list
      else
        action = :get_list
      end
    else
      attribute_name = method_name
      action = :get
    end

    field = custom_field(attribute_name, required: false)
    if field
      [attribute_name, action, field]
    else
      nil
    end
  end


end
