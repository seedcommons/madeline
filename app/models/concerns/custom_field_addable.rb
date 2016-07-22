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
    # Note, if division is provided that takes precedence over the model param.  i
    # If no division provided, the model's division is used.  If neither provided, then the root division is used.
    # This method is overridden for CustomValueSet which has its field set explicitly assigned based on the link context
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

    # Returns true if the referenced attribute name corresponds to a custom field for the given division/model object.
    def custom_field?(field_identifier, division: nil, model: nil)
      field_set = resolve_custom_field_set(division: division, model: model, required: false)
      field_set && field_set.field(field_identifier, required: false).present?
    end

  end


  def ensured_custom_data
    self.custom_data ||= {}
    self.custom_data  # this explicit return value is important!
  end

  # Change/assign custom field value and immediate persist
  def update_custom_value(field_identifier, value)
    data = set_custom_value(field_identifier, value)
    self.update(custom_data: data)
  end

  # Change/assign custom field value, but leave as tranient
  def set_custom_value(field_identifier, value)
    if (field_identifier.is_a? String) && field_identifier.include?('__')
      parts = field_identifier.split('__')
      field_identifier = parts[0]
      nested_attribute = parts[1]
    end

    field = custom_field(field_identifier)  # note, this is fatal if field not found
    if field.translatable?
      set_translation(field.json_key, value)
    else
      data = ensured_custom_data
      # future: value manipulation depending on field data type
      if nested_attribute
        hash = data[field.json_key] || {}
        hash[nested_attribute] = value
        data[field.json_key] = hash
      else
        data[field.json_key] = value
      end
      data
    end
  end

  # Fetches a custom value from the json field
  def custom_value(field_identifier)
    if (field_identifier.is_a? String) && field_identifier.include?('__')
      parts = field_identifier.split('__')
      field_identifier = parts[0]
      nested_attribute = parts[1]
    end
    field = custom_field(field_identifier)
    raw_value = ensured_custom_data[field.json_key]
    # 4301 Todo: '< 200' implies LoanResponse field.  Need to either add something to custom field
    # schema to drive this marshalling or do a wider refactor to be less generic.
    value = wrap_as_loan_response? ? LoanResponse.new(field, raw_value, self) : raw_value
    if nested_attribute
      value.send(nested_attribute)
    else
      value
    end
  end

  # def custom_value_hash(field_identifier)
  #   field = custom_field(field_identifier)
  #   value_hash = ensured_custom_data[field.json_key]
  # end

  # Determines and returns which custom field set definition corresponds to this object instance, based on the owning division
  # Raises an exception if no custom field set definition is found.
  # todo: consider making 'required: false' the default
  def resolve_custom_field_set(required: true)
    self.class.resolve_custom_field_set(model: self, required: required)
  end

  # Returns the CustomField instance corresponding to the given attribute name for the current object
  def custom_field(field_identifier, required: true)
    field_set = resolve_custom_field_set(required: required)
    field_set.field(field_identifier, required: required)  if field_set
  end

  # Returns true if the referenced attribute name corresponds to a custom field for the current object
  def custom_field?(field_identifier)
    self.class.custom_field?(field_identifier, model: self)
  end

  #
  # Defines dynamic method handlers for custom fields as if they were natural attributes, including special
  # awareness of translatable custom fields.
  #
  # For non-translatable custom fields, equivalent to:
  #
  # def foo
  #   custom_value('foo')
  # end
  #
  # def foo=(value)
  #   set_custom_value('foo', value)
  # end
  #
  # def update_foo
  #   update_custom_value('foo', value)  #immediately persists
  # end
  #
  #
  # For translatable custom fields, equivalent to:
  #
  # def foo
  #   get_translation('foo')  # returns Translation instance
  # end
  #
  # def foo=(value)
  #   set_translation('foo', value)
  # end
  #
  # def foo_translations
  #   get_translations('foo')  # list of all translations for associated field
  # end
  #
  # def foo_translations=(values)
  #   set_translations('foo', values)  # assigns a collection of translations
  # end
  #
  def method_missing(method_sym, *arguments, &block)
    #puts "method missing - #{method_sym}"
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
    #puts "respond to missing: #{method_sym} - self: #{self}"
    attribute_name, action = match_dynamic_method(method_sym)
    if action
      true
    else
      super
    end
  end

  # Determines attribute name and implied operations for dynamic methods as documented above
  def match_dynamic_method(method_sym)
    method_name = method_sym.to_s

    # avoid problems with nested attribute methods and form helpers
    return nil if method_name.end_with?('came_from_user?')
    return nil if method_name.end_with?('before_type_cast')
    return nil if method_name == 'policy_class'
    return nil if method_name == 'to_ary'

    if method_name.ends_with?('=')
      attribute_name = method_name.chomp('=')
      action = :set
    elsif method_name.starts_with?('update_')
      attribute_name = method_name.sub('update_', '')
      action = :update
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

    if attribute_name.include?('__')
      parts = attribute_name.split('__')
      field_name = parts[0]
    else
      field_name = attribute_name
    end

    field = custom_field(field_name, required: false)
    if field
      [attribute_name, action, field]
    else
      nil
    end
  end

  private

  def wrap_as_loan_response?
    # Beware, this assumes CustomValueSet records are always loan response records.  If that changes
    # then a wider refactor will be needed.
    self.class == CustomValueSet
  end

end
