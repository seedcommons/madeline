class ResponseSet < ApplicationRecord
  belongs_to :loan
  belongs_to :updater, class_name: 'User'
  belongs_to :question_set, inverse_of: :response_sets
  has_many :answers, dependent: :destroy
  accepts_nested_attributes_for :answers

  validates :loan, presence: true

  delegate :division, :division=, to: :loan

  after_commit :recalculate_loan_health

  def self.find_with_loan_and_kind(loan, kind)
    joins(:question_set).find_by(loan: loan, question_sets: {kind: kind})
  end

  def recalculate_loan_health
    RecalculateLoanHealthJob.perform_later(loan_id: loan_id)
  end

  def answer_for_question(question)
    @answers ||= answers
    @answers.select{ |a| a.question_id == question.id }.try(:first)
  end

  def question_blank?(question)
    if question.group?
      question.children.all?{|c| question_blank?(c)}
    else
      answer_for_question(question).blank?
    end
  end

  # Fetches urls of all embeddable media in the whole custom value set
  def embedded_urls
    return [] if custom_data.blank?
    custom_data.values.map { |v| v["url"].presence }.compact
  end


  def custom_data_from_answers
    response_custom_data_json = {}
    answers.each do |answer|
      response_custom_data_json[answer.question.json_key] = answer.custom_data_json
    end
    return response_custom_data_json
  end

  def make_answers
    custom_data.each do |q_id, response_data|
      question = Question.find(q_id)
      if question.present?
        begin
          Answer.save_from_form_field_params(question, response_data, self)
        rescue => e
          puts "Q #{question.id} #{question.data_type}"
          puts response_data
          raise e
        end
      end
    end
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
  # This method is used to save response_sets in the controler. They come
  # back to the server with params that are internal names of questions e.g. "field_110="
  # Rails calls method_missing since these aren't attrs of a response set,
  # and this method then calls response(q) and set_response(q) instead of erroring.
  # it uses Rail's under the hood iteration over params from the request
  # As of May 2022 'get' action not used anywhere.

  private

  # Gets the question for the given identifier. Decorates it if it's not already.
  def question(identifier, required: true)
    ensure_decorated(question_set.question(identifier, required: required))
  end

  def ensure_decorated(question)
    question.nil? || question.decorated? ? question : LoanFilteredQuestion.new(question, loan: loan)
  end

  def is_number?(object)
    true if Float(object) rescue false
  end

  def is_number_or_blank?(object)
    true if object.blank? || Float(object) rescue false
  end
end
