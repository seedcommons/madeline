# == Schema Information
#
# Table name: loan_response_sets
#
#  created_at   :datetime         not null
#  custom_data  :json
#  id           :integer          not null, primary key
#  kind         :string
#  loan_id      :integer          not null
#  lock_version :integer          default(0), not null
#  updated_at   :datetime         not null
#  updater_id   :integer
#
# Foreign Keys
#
#  fk_rails_4142299b55  (updater_id => users.id)
#

class LoanResponseSet < ActiveRecord::Base
  belongs_to :loan
  belongs_to :updater, class_name: 'User'

  validates :loan, presence: true

  delegate :division, :division=, to: :loan
  delegate :progress, :progress_pct, :progress_type, to: :root_response

  after_commit :recalculate_loan_health

  def recalculate_loan_health
    RecalculateLoanHealthJob.perform_later(loan_id: loan_id)
  end

  def question_set
    @question_set ||= LoanQuestionSet.find_by(internal_name: "loan_#{kind}")
  end

  def root_response
    response(question(:root))
  end

  # Fetches a custom value from the json field.
  # Ensures `question` is decorated before passing to LoanResponse.
  def response(question)
    question = ensure_decorated(question)
    raw_value = (custom_data || {})[question.json_key]
    LoanResponse.new(loan: loan, loan_question: question, loan_response_set: self, data: raw_value)
  end

  # Change/assign custom field value, but don't save.
  def set_response(question, value)
    self.custom_data ||= {}
    custom_data[question.json_key] = value
    custom_data
  end

  # Fetches urls of all embeddable media in the whole custom value set
  def embedded_urls
    return [] if custom_data.blank?
    custom_data.values.map { |v| v["url"].presence }.compact
  end

  # Defines dynamic method handlers for custom fields as if they were natural attributes, including special
  # awareness of translatable custom fields.
  #
  # For non-translatable custom fields, equivalent to:
  #
  # def foo
  #   response('foo')
  # end
  #
  # def foo=(value)
  #   set_response('foo', value)
  # end
  def method_missing(method_sym, *arguments, &block)
    attribute_name, action, field = match_dynamic_method(method_sym)
    if action
      q = question(attribute_name)
      case action
      when :get then return response(q)
      when :set then return set_response(q, arguments.first)
      end
    end
    super
  end

  def respond_to_missing?(method_sym, include_private = false)
    attribute_name, action = match_dynamic_method(method_sym)
    action ? true : super
  end

  private

  # Gets the question for the given identifier. Decorates it if it's not already.
  def question(identifier, required: true)
    ensure_decorated(question_set.question(identifier, required: required))
  end

  def ensure_decorated(question)
    question.nil? || question.decorated? ? question : LoanFilteredQuestion.new(question, loan: loan)
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

    field = question(attribute_name, required: false)
    if field
      [attribute_name, action, field]
    else
      nil
    end
  end

  def is_number?(object)
    true if Float(object) rescue false
  end

  def is_number_or_blank?(object)
    true if object.blank? || Float(object) rescue false
  end
end
