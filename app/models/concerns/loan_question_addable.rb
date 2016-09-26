module LoanQuestionAddable
  extend ActiveSupport::Concern

  def loan_question(field_identifier, required: true)
    loan_question_set.field(field_identifier, required: required)
  end

  # Change/assign custom field value, but leave as tranient
  def set_custom_value(field_identifier, value)
    field = loan_question(field_identifier)
    self.custom_data ||= {}
    custom_data[field.json_key] = value
    custom_data
  end

  # Fetches a custom value from the json field. `field_identifier` can be the same
  def custom_value(field_identifier)
    field = loan_question(field_identifier)
    raw_value = (custom_data || {})[field.json_key]
    LoanResponse.new(loan: loan, loan_question: field, loan_response_set: self, data: raw_value)
  end

  def tree_unanswered?(root_identifier)
    field = loan_question(root_identifier)
    field.self_and_descendants.all? { |i| custom_value(i.id).blank? }
  end

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
  def method_missing(method_sym, *arguments, &block)
    attribute_name, action, field = match_dynamic_method(method_sym)
    if action
      case action
      when :get then return custom_value(attribute_name)
      when :set then return set_custom_value(attribute_name, arguments.first)
      end
    end
    super
  end

  def respond_to_missing?(method_sym, include_private = false)
    attribute_name, action = match_dynamic_method(method_sym)
    action ? true : super
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
