class ResponseSet < ApplicationRecord
  belongs_to :loan
  belongs_to :updater, class_name: 'User'
  belongs_to :question_set, inverse_of: :response_sets
  has_many :answers, dependent: :destroy
  accepts_nested_attributes_for :answers

  validates :loan, presence: true

  delegate :division, :division=, to: :loan
  delegate :progress, :progress_pct, :progress_type, to: :root_response

  after_commit :recalculate_loan_health

  def self.find_with_loan_and_kind(loan, kind)
    joins(:question_set).find_by(loan: loan, question_sets: {kind: kind})
  end

  def recalculate_loan_health
    RecalculateLoanHealthJob.perform_later(loan_id: loan_id)
  end

  def answer_for_question(question)
    answers.select{ |a| a.question_id == question.id }.try(:first)
  end

  def question_blank?(question)
    if question.group?
      question.children.all?{|c| question_blank?(c)}
    else
      answer_for_question(question).blank?
    end
  end

  def root_response
    response(question(:root))
  end

  # Fetches a custom value from the json field.
  # Ensures `question` is decorated before passing to Response.
  def response(question)
    question = ensure_decorated(question)
    answer = answer_for_question(question)
    raw_value = answer.present? ? answer.raw_value : nil
    Response.new(loan: loan, question: question, response_set: self, data: raw_value)
  end

  # # this method is temporary for spr 2022 overhaul, for migration
  def ensure_all_answers_copied
    answer_q_ids = answers.pluck(:question_id).sort
    # select q ids where the response is not blank
    custom_data_q_ids = custom_data.keys.select do |q_id|
      rs = Response.new(loan: loan, question: Question.find(q_id), response_set: self, data: custom_data[q_id])
      return !rs.blank?
    end.sort
    unless answer_q_ids == custom_data_q_ids
      qs_in_answers_only = answer_q_ids - custom_data_q_ids
      qs_in_custom_data_only = custom_data_q_ids - answer_q_ids
      raise "ERROR for rs #{id}: Diff between questions in answers and custom data. In answer only: #{qs_in_answers_only}. In custom data only: #{qs_in_custom_data_only}"
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
