# Represents multi-value loan criteria or post analysis questionnaire response.
# Currently a wrapper around CustomFieldAddable data, but should perhaps refactor and promote
# to a its own db table

class LoanResponse
  include ProgressCalculable

  attr_accessor :loan
  attr_accessor :loan_question
  attr_accessor :loan_response_set
  attr_accessor :text
  attr_accessor :number
  attr_accessor :boolean
  attr_accessor :rating
  attr_accessor :url
  attr_accessor :start_cell
  attr_accessor :end_cell
  attr_accessor :owner
  attr_accessor :breakeven
  attr_accessor :business_canvas

  delegate :group?, to: :loan_question

  def initialize(loan:, loan_question:, loan_response_set:, data:)
    data = (data || {}).with_indifferent_access
    @loan = loan
    @loan_question = loan_question
    @loan_response_set = loan_response_set
    @text = data[:text]
    @number = data[:number]
    @boolean = data[:boolean]
    @rating = data[:rating]
    @url = data[:url]
    @start_cell = data[:start_cell]
    @end_cell = data[:end_cell]
    @breakeven = remove_blanks data[:breakeven]
    @business_canvas = data[:business_canvas]
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
    @field_attributes ||= loan_question.value_types
  end

  def has_text?
    field_attributes.include?(:text)
  end

  def has_number?
    field_attributes.include?(:number)
  end

  def has_rating?
    field_attributes.include?(:rating)
  end

  def has_linked_document?
    field_attributes.include?(:url)
  end

  def has_boolean?
    field_attributes.include?(:boolean)
  end

  def has_breakeven_table?
    field_attributes.include?(:breakeven)
  end

  def has_business_canvas?
    field_attributes.include?(:business_canvas)
  end

  def blank?
    text.blank? && number.blank? && rating.blank? && boolean.blank? && url.blank? &&
      breakeven_report.blank? && business_canvas_blank?
  end

  def business_canvas_blank?
    business_canvas.blank? || business_canvas.values.all?(&:blank?)
  end

  def answered?
    !blank?
  end

  # Allows for one line string field to also be presented for 'rating' typed fields
  def text_form_field_type
    loan_question.data_type == 'text' ? :text : :string
  end

  def required?
    @required ||= loan_question.required_for?(loan)
  end

  private

  # Gets child responses of this response by asking LoanResponseSet.
  # Assumes LoanResponseSet's implementation will be super fast (not hitting DB everytime), else
  # performance will be horrible in recursive methods.
  def kids
    @kids ||= loan_response_set.kids_of(self)
  end

  def remove_blanks(data)
    if data
      data['products'].delete_if { |i| i.values.all?(&:blank?) }
      data['fixed_costs'].delete_if { |i| i.values.all?(&:blank?) }
    end
    data
  end
end
