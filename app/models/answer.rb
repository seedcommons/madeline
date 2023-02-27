class Answer < ApplicationRecord
  belongs_to :response_set,  optional: false
  belongs_to :question, optional: false
  delegate :data_type, to: :question
  validate :question_is_not_group
<<<<<<< HEAD
  validates_presence_of :question_id
=======
>>>>>>> 12179_answers_migration
  validate :question_set_matches

  before_save :ensure_json_format
  before_save :clean_breakeven


  def ensure_json_format
    business_canvas_data = business_canvas_data.to_json
    breakeven_data = breakeven_data.to_json
  end

  def clean_breakeven
    return unless breakeven_data
    clean_breakeven_products = []
    if breakeven_data["products"]
      breakeven_data["products"].each do |p|
        clean_breakeven_products << p unless p.values.reject(&:blank?).empty?
      end
      breakeven_data["products"] = clean_breakeven_products
    end
    if breakeven_data["fixed_costs"]
      clean_fixed_costs = []
      breakeven_data["fixed_costs"].each do |fc|
        clean_fixed_costs << fc unless fc.values.reject(&:blank?).empty?
      end
      breakeven_data["fixed_costs"] = clean_fixed_costs
    end
    unless question.question_set_id == response_set.question_set_id
      raise "ERROR for answer #{id}: question set has id #{question.question_set_id}, response set has qset id #{response_set.question_set_id}"
    end
  end

  def self.json_answer_blank?(answer_json)
    answer_json.values.all?{|v| v.blank?}
  end

  def json_answer_blank?(answer_json)
    answer_json.values.all?{|v| v.blank?}
  end

  def to_s
    "RS: #{response_set.question_set.kind}, Q id: #{question.id}, Q: #{question.label.to_s} | NA: #{not_applicable}; text: #{text_data}; numeric: #{numeric_data}; boolean: #{boolean_data}; doc: #{linked_document_data}; breakeven: #{breakeven_data}; canvas: #{business_canvas_data}"
  end

  def blank?
    !not_applicable &&
    text_data.blank? &&
    numeric_data.blank? &&
    boolean_data.nil? &&
    linked_document_data_blank? &&
    business_canvas_blank? &&
    breakeven_data_blank?
  end

  def applicable?
    !not_applicable
  end

  def text
    text_data
  end

  def boolean
    boolean_data
  end

  def number
    numeric_data
  end
  # can we get rid of rating as a concept? its very confusing. no it is limited to 1-5.
  def rating
    numeric_data
  end

  def breakeven_table
    @breakeven_table ||= BreakevenTableQuestion.new(breakeven_data)
  end

  def breakeven_hash
    @breakeven_hash ||= breakeven_table.data_hash
  end

  def business_canvas
    business_canvas_data.symbolize_keys if business_canvas_data
  end

<<<<<<< HEAD
  def breakeven_report
    @breakeven_report ||= breakeven_table.report
  end

  def linked_document_data_blank?
    linked_document_data.blank? || linked_document_data.values.all?{|v| v.blank?}
  end

  def business_canvas_blank?
    business_canvas_data.blank? || self.json_answer_blank?(business_canvas_data)
  end

  def breakeven_data_blank?
    breakeven_data.blank? || self.json_answer_blank?(breakeven_data)
  end

  def linked_document
    if linked_document_data.present?
      LinkedDocument.new(linked_document_data.symbolize_keys)
    else
      nil
=======
  def question_set_matches
    question.question_set_id == response_set.question_set_id
  end

  # temp method for spr 2022 overhaul
  def raw_value
    json = {}
    json["not_applicable"] = self.not_applicable ? "yes" : "no"
    if self.text_data.present?
      json["text"] = self.text_data
    end
    unless self.boolean_data.nil?
      json["boolean"] =  self.boolean_data ? "yes" : "no"
    end
    if self.breakeven_data.present?
      json["breakeven"] = self.breakeven_data
    end
    if self.business_canvas_data.present?
      json["business_canvas"] = self.business_canvas_data
    end
    if self.numeric_data.present?
      if self.question.data_type == "range"
        json["rating"] = self.numeric_data
      else
        json["number"] = self.numeric_data
      end
    end
    if self.linked_document_data.present?
      json["url"] = self.linked_document_data["url"]
      json["start_cell"] = self.linked_document_data["start_cell"]
      json["end_cell"] = self.linked_document_data["end_cell"]
>>>>>>> 12179_answers_migration
    end
  end

  def question_is_not_group
    question.data_type != "group"
  end

  def question_set_matches
    question.question_set_id == response_set.question_set_id
  end

  def answer_for_csv(allow_text_like_numeric: false)
    return nil if not_applicable

    case question.data_type
    when "text"
      text_data
    when "number", "currency", "percentage", "range"
      if allow_text_like_numeric || (true if Float(numeric_data) rescue false)
       numeric_data.to_s
      else
        nil
      end
    when "boolean"
      boolean_data.nil? ? nil : (boolean_data ? "yes" : "no")
    # "breakeven" and "business_canvas" never exported to csv
    else
      raise "invalid question data type #{question.data_type}"
    end
  end
end
