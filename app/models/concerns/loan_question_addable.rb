#
# Encapsulates associating a schema of custom fields to a model type and getting/setting values stored into a
# JSON field on the model instance.
# Assumes that a JSON db column named 'custom_data' exists.  (future: allow this column name to be customized)
#

# REFACTOR: move into LoanResponseSet
module LoanQuestionAddable
  extend ActiveSupport::Concern

  # REFACTOR: remove
  include Translatable

  # Returns the LoanQuestion instance corresponding to the given attribute name for the current object
  def loan_question(field_identifier, required: true)
    loan_question_set.field(field_identifier, required: required)
  end

  # Change/assign custom field value and immediate persist
  def update_custom_value(field_identifier, value)
    data = set_custom_value(field_identifier, value)
    self.update(custom_data: data)
  end

  # Change/assign custom field value, but leave as tranient
  def set_custom_value(field_identifier, value)
    field = loan_question(field_identifier)
    if field.translatable?
      set_translation(field.json_key, value)
    else
      self.custom_data ||= {}
      # future: value manipulation depending on field data type
      custom_data[field.json_key] = value
      custom_data
    end
  end

  # Fetches a custom value from the json field
  def custom_value(field_identifier)
    if field_identifier.is_a? LoanQuestion
      field = field_identifier
    else
      field = loan_question(field_identifier)
    end

    raw_value = (custom_data || {})[field.json_key]
    LoanResponse.new(loan: loan, loan_question: field, loan_response_set: self, data: raw_value)
  end

  def tree_unanswered?(root_identifier)
    # Note: Raises error if field not found
    field = loan_question_set.field(root_identifier)
    field.self_and_descendants.all? { |i| custom_value(i.id).blank? }
  end

  # REFACTOR: remove
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

    field = loan_question(attribute_name, required: false)
    if field
      [attribute_name, action, field]
    else
      nil
    end
  end
end
