# Represents multi-value loan criteria or post analysis questionnaire response.
class Response
  include ProgressCalculable

  attr_accessor :loan, :question, :response_set, :text, :number, :boolean,
    :rating, :url, :start_cell, :end_cell, :owner, :breakeven, :business_canvas, :not_applicable

  delegate :group?, :active?, :required?, to: :question

  TYPES = %i(boolean breakeven business_canvas currency number percentage rating text url)

  def initialize(loan:, question:, response_set:, data:)
    data = (data || {}).with_indifferent_access
    @loan = loan
    @question = question
    @response_set = response_set
    %w(boolean business_canvas end_cell number rating start_cell not_applicable text url).each do |i|
      instance_variable_set("@#{i}", data[i.to_sym])
    end
    @breakeven = remove_blanks(data[:breakeven])
  end

  def model_name
    'Response'
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

  # Checks if response is blank, including any descendants if this is a group.
  def blank?
    if group?
      children.all?(&:blank?) || children.all?(&:not_applicable?)
    else
      !not_applicable? && text.blank? && number.blank? && rating.blank? &&
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

  # Boolean attributes are currently stored as "yes"/"no" in the ResponseSet data. This could
  # get refactored in future to use actual booleans.
  def not_applicable?
    not_applicable == "yes"
  end

  private

  # Gets child responses of this response by asking ResponseSet.
  # Assumes ResponseSet's implementation of `response`
  # will be super fast (not hitting DB everytime), else
  # performance will be horrible in recursive methods.
  def children
    question.children.map { |q| response_set.response(q) }
  end

  def remove_blanks(data)
    if data
      data['products'].delete_if { |i| i.values.all?(&:blank?) }
      data['fixed_costs'].delete_if { |i| i.values.all?(&:blank?) }
    end
    data
  end
end
