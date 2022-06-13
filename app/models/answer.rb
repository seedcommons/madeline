class Answer < ApplicationRecord
  belongs_to :response_set,  optional: false
  belongs_to :question, optional: false
  delegate :data_type, to: :question
  validate :question_is_not_group
  validates_presence_of :question_id

  before_save :ensure_json_format

  def ensure_json_format
    puts "+++++++raw"
    puts business_canvas_data
    business_canvas_data = business_canvas_data.to_json
    breakeven_data = breakeven_data.to_json
    puts "++++++after"
    puts business_canvas_data
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
    !not_applicable? &&
    text_data.blank? &&
    numeric_data.blank? &&
    boolean_data.blank? &&
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
    end
  end



  # expects 'raw_value' type json e.g. the value of a "field_110" key in form submission
  # or the value of a q_id key e.g. "5126" in custom_data
  def self.contains_answer_data?(hash_data)
    hash_data.each do |key, value|
      if %w(text number rating url start_cell end_cell).include?(key)
        return true unless value.blank?
      elsif key == "not_applicable"
        return true if value == "yes"
      elsif key == "boolean"
        return true unless (value.nil? || value.empty?)
      elsif %w(business_canvas).include?(key)
        return true unless self.json_answer_blank?(value)
      elsif %w(breakeven).include?(key)
        value.each do |subkey, subvalue|
          if %w(products fixed_costs).include?(subkey)
            subvalue.each {|i| return true unless self.json_answer_blank?(i)}
          else
            return true unless subvalue.empty?
          end
        end
      end
    end
    return false
  end

  def question_is_not_group
    question.data_type != "group"
  end

  def has_data
    errors.add("Answer contains no data") unless
      not_applicable ||
      text_data.present? ||
      numeric_data.present? ||
      !boolean_data.nil? ||
      linked_document_data.present? ||
      business_canvas_data.present? ||
      breakeven_data.present?
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
    end
    json
  end

  # temp method for spr 2022 overhaul
  # return the value of json that would be in legacy custom_data field on response set for this answer's question
  def custom_data_json
    return {"#{self.question.json_key}": self.raw_value}
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
