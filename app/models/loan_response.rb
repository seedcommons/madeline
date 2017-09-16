# Represents multi-value loan criteria or post analysis questionnaire response.
class LoanResponse
  include ProgressCalculable

  attr_accessor :loan, :question, :loan_response_set, :text, :string, :number, :boolean,
    :rating, :url, :start_cell, :end_cell, :owner, :breakeven, :business_canvas, :not_applicable

  delegate :group?, :active?, :required?, to: :question

  TYPES = %i(text string number rating boolean url breakeven business_canvas)

  def initialize(loan:, question:, loan_response_set:, data:)
    data = (data || {}).with_indifferent_access
    @loan = loan
    @question = question
    @loan_response_set = loan_response_set
    %w(text string number boolean rating url start_cell end_cell business_canvas not_applicable).each do |i|
      instance_variable_set("@#{i}", data[i.to_sym])
    end
    @breakeven = remove_blanks(data[:breakeven])
  end

  def model_name
    'LoanResponse'
  end

  def linked_document
    if url.present?
      LinkedDocument.new(url, start_cell: start_cell, end_cell: end_cell)
    else
      nil
    end
  end

  def breakeven_table
    @breakeven_table ||= BreakevenTableQuestion.new(breakeven)
  end

  def breakeven_hash
    @breakeven_hash ||= breakeven_table.data_hash
  end

  def breakeven_report
    @breakeven_report ||= breakeven_table.report
  end

  def field_attributes
    @field_attributes ||= question.value_types
  end

  TYPES.each do |type|
    define_method("has_#{type}?") do
      field_attributes.include?(type)
    end
  end

  # Checks if response is blank, including any descenants if this is a group.
  def blank?
    if group?
      question.children.all?(&:blank?)
    else
      !not_applicable? && text.blank? && string.blank? && number.blank? && rating.blank? &&
        boolean.blank? && url.blank? && breakeven_report.blank? && business_canvas_blank?
    end
  end

  def business_canvas_blank?
    business_canvas.blank? || business_canvas.values.all?(&:blank?)
  end

  def answered?
    !blank?
  end

  # Allows for one line string field to also be presented for 'rating' typed fields
  def text_form_field_type
    question.data_type == 'text' ? :text : :string
  end

  # Boolean attributes are currently stored as "yes"/"no" in the LoanResponseSet data. This could
  # get refactored in future to use actual booleans.
  def not_applicable?
    not_applicable == "yes"
  end

  private

  # Gets child responses of this response by asking LoanResponseSet.
  # Assumes LoanResponseSet's implementation of `response`
  # will be super fast (not hitting DB everytime), else
  # performance will be horrible in recursive methods.
  def children
    question.children.map { |q| loan_response_set.response(q) }
  end

  def remove_blanks(data)
    if data
      data['products'].delete_if { |i| i.values.all?(&:blank?) }
      data['fixed_costs'].delete_if { |i| i.values.all?(&:blank?) }
    end
    data
  end
end
