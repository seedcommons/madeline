class Answer < ApplicationRecord
  belongs_to :response_set,  optional: false
  belongs_to :question, optional: false
  delegate :data_type, to: :question
  validate :has_data
  validate :question_is_not_group
  validates_presence_of :question_id

  def self.json_answer_blank?(answer_json)
    answer_json.values.all?{|v| v.blank?}
  end

  def json_answer_blank?(answer_json)
    answer_json.values.all?{|v| v.blank?}
  end

  # this method is temporary for spr 2022 overhaul
  def compare_to_custom_data
    custom_data_raw_data = response_set.custom_data[question.id.to_s]
    custom_data_response = Response.new(loan: response_set.loan, question: question, response_set: response_set, data: custom_data_raw_data)
    answer_response = Response.new(loan: response_set.loan, question: question, response_set: response_set, data: raw_value)
    methods = [:loan, :question, :response_set, :text, :number, :boolean, :rating, :url, :start_cell, :end_cell, :owner, :breakeven, :business_canvas, :not_applicable]
    methods.each do |m|
      custom_data_value = custom_data_response.send(m)
      answer_value = answer_response.send(m)
      unless custom_data_value == answer_value
        raise "ERROR for answer #{id}: for RS #{response_set.id} custom data value for #{m} is #{custom_data_value} but is #{answer_value} for answer #{id}"
      end
    end
  end

  def to_s
    "RS: #{response_set.question_set.kind}, Q: #{question.label.to_s} | NA: #{not_applicable}; text: #{text_data}; numeric: #{numeric_data}; boolean: #{boolean_data}; doc: #{linked_document_data}; breakeven: #{breakeven_data}; canvas: #{business_canvas_data}"
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

  def text
    text_data
  end

  def boolean
    boolean_data
  end

  def number
    numeric_data
  end
  # can we get rid of rating as a concept? its very confusing
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
    business_canvas_data
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
      LinkedDocument.new(linked_document_data)
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

  # this method is temporary for spr 2022 overhaul
  # doesn't save blank answers
  def self.save_from_form_field_params(question, fields, response_set)
    unless question.group? || !self.contains_answer_data?(fields)
      not_applicable = fields.key?("not_applicable") ? (fields["not_applicable"] == "yes") : "no"
      text_data = fields.key?("text") ? fields["text"] : nil
      numeric_data = if fields.key?("number")
          fields["number"]
        elsif fields.key?("rating")
          fields["rating"]
        else
          nil
        end
      boolean_data = if fields.key?("boolean")
        case  fields["boolean"]
        when "yes"
          true
        when "no"
          false
        else
          nil
        end
      end
      breakeven_data = fields.key?("breakeven") ? fields["breakeven"] : nil
      business_canvas_data = fields.key?("business_canvas") ? fields["business_canvas"] : nil
      linked_document_data = fields.key?("url") ? {"url": fields["url"] } : {"url": ""}
      linked_document_data["start_cell"] = fields.key?("start_cell") ? fields["start_cell"] : ""
      linked_document_data["end_cell"] = fields.key?("end_cell") ? fields["end_cell"] : ""
      answer = Answer.find_or_create_by(response_set: response_set, question: question)
      answer.update!({
          not_applicable: not_applicable,
          text_data: text_data,
          numeric_data: numeric_data,
          boolean_data: boolean_data,
          breakeven_data: breakeven_data,
          business_canvas_data: business_canvas_data,
          linked_document_data: linked_document_data
        })
    end
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
