class ResponseSet < ApplicationRecord
  belongs_to :loan
  belongs_to :updater, class_name: 'User'
  belongs_to :question_set, inverse_of: :response_sets
  has_many :answers, dependent: :destroy
  accepts_nested_attributes_for :answers

  # amoeba gem needed here to include answers in project duplication
  amoeba do
    enable
    propagate
  end

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

  # supporting specs
  def root_response
    root = LoanFilteredQuestion.new(question_set.root_group_preloaded, loan: loan, response_set: self)
    # todo: there must be a better way to 'ensure decorated'
    root
  end

  # call only in background (currently used in loan health check);
  # very expensive method
  def progress_pct
    root_response.progress_pct
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

  def is_number?(object)
    true if Float(object) rescue false
  end

  def is_number_or_blank?(object)
    true if object.blank? || Float(object) rescue false
  end
end
