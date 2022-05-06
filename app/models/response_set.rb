class ResponseSet < ApplicationRecord
  belongs_to :loan
  belongs_to :updater, class_name: 'User'
  belongs_to :question_set, inverse_of: :response_sets
  has_many :answers, dependent: :destroy

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

  def question_blank?(question)
    if question.group?
      question.children.all?{|c| question_blank?(c)}
    else
      Answer.where(question_id: question.id, response_set_id: self.id).blank?
    end
  end

  def root_response
    response(question(:root))
  end

  # Fetches a custom value from the json field.
  # Ensures `question` is decorated before passing to Response.
  def response(question)
    puts "QUestion in response(question) in response set"
    puts question
    puts "#"
    question = ensure_decorated(question)
    answer = Answer.find_by(response_set: self, question: question)
    puts answer.nil?
    Answer.all.each{|a| puts a.to_s}
    raw_value = answer.present? ? answer.raw_value : nil
    puts "raw value for response made from question:"
    Response.new(loan: loan, question: question, response_set: self, data: raw_value)
  end

  # for migration
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

  def save_answers(form_hash)
    puts "save answers in response set model with:"
    puts form_hash
    form_hash.each do |key, value|
      if key.include?("field") # key is an internal_name of a question
        question = Question.find_by(internal_name: key)
        Answer.save_from_form_field_params(question, value, self)
      end
    end
  end

  # for specs in overhaul
  def set_answer_from_custom_data_style_json(question, value)
    Answer.save_from_form_field_params(question, value, self)
  end

  # Change/assign custom field value, but don't save.
  # WHY do we not save here? probably just to save db writes
  # THIS is where the question internal_name (e.g. field_110) coming form jqtree gets converted back to
  # the question id that is the key in the response set's custom_data.
  # so we can use the question.id and self.id to find an answer record.
  def set_response(question, value)
    #TODO: find or create answer record by question id and self.id
    # call a new method on answer that takes value and saves the fields
    # i don't THINK we actually need to return custom data, but if we
    # have to, we'll call a method on answer model that composes custom_data equivalent.
    self.custom_data ||= {}
    custom_data[question.json_key] = value
    custom_data
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
  # it basically uses Rail's under the hood iteration over params from the request
  # in lieu of writing our own.
  # so far I am unclear where the get version happens . . .
  def method_missing(method_sym, *arguments, &block)
    attribute_name, action, field = match_dynamic_method(method_sym)
    if action
      # the question is retrieved based on the internal name coming back
      # from jqtree as the fake "attribute" prompting the method_missing call. in set_response,
      # we then convert from internal name to the question id in set_response.
      q = question(attribute_name)
      case action
      when :get
        puts "GET in method missing with #{q}"
        #return response(q)
      when :set
        puts "SET in method missing with #{q}"
        return set_response(q, arguments.first)
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

    # the attribute name here is internal_name coming from the _answer.html.slim
    # where the questionnaire form uses "question.attribute_sym" and attribute_sym is the internal name
    # (see question.rb line 72)
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
