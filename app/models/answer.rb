class Answer < ApplicationRecord
  belongs_to :response_set,  optional: false
  belongs_to :question, optional: false
  delegate :data_type, to: :question

  # TODO consider bringing back when frontend can support no answer existing
  # =========================================================================
  with_options if: ->(answer) { answer&.question&.data_type == "boolean" } do |boolean_answer|
    boolean_answer.validates :boolean_data, presence: true
  end
  with_options if: ->(answer) { %w(rating range currency number percentage).include?(answer&.question&.data_type)  } do |numeric_answer|
    numeric_answer.validates :numeric_data, presence: true
  end
  with_options if: ->(answer) { %w(text).include?(answer&.question&.data_type)  } do |text_answer|
    text_answer.validates :text_data, presence: true
  end
  with_options if: ->(answer) { %w(text).include?(answer&.question&.data_type)  } do |text_answer|
    text_answer.validates :text_data, presence: true
  end
  with_options if: ->(answer) { %w(range).include?(answer&.question&.data_type)  } do |range_answer|
    range_answer.validate :has_rating_or_text
  end
  validate :question_is_not_group

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

  def self.no_answer?(q, fields, response_set)
    puts fields
    puts fields.class
    response = Response.new(loan: response_set.loan, response_set: response_set, question: q, data: fields)
    return response.blank?
  end

  # this method is temporary for spr 2022 overhaul
  # doesn't save blank answers
  def self.save_from_form_field_params(q_internal_name, fields, response_set)
    q = Question.find_by(internal_name: q_internal_name)
    unless self.no_answer?(q, fields.to_h, response_set)
      not_applicable = fields.key?("not_applicable") ? (fields["not_applicable"] == "yes") : "no"
      text_data = fields.key?("text") ? fields["text"] : nil
      numeric_data = if fields.key?("number")
          fields["number"]
        elsif fields.key?("rating")
          fields["rating"]
        else
          nil
        end
      boolean_data = fields.key?("boolean") ? (fields["boolean"] == "yes") : "no"
      breakeven_data = fields.key?("breakeven") ? fields["breakeven"] : nil
      business_canvas_data = fields.key?("business_canvas") ? fields["business_canvas"] : nil
      linked_document_data = fields.key?("url") ? {"url": fields["url"] } : {"url": ""}
      linked_document_data["start_cell"] = fields.key?("start_cell") ? fields["start_cell"] : ""
      linked_document_data["end_cell"] = fields.key?("end_cell") ? fields["end_cell"] : ""
      answer = Answer.find_or_create_by(response_set: response_set, question: q)
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

  def has_rating_or_text
    numeric_data.present? || text_data.present?
  end

  # temp method for spr 2022 overhaul
  def raw_value
    json = {}
    json["not_applicable"] = self.not_applicable ? "yes" : "no"
    if self.text_data.present?
      json["text"] = self.text_data
    end
    if self.boolean_data.present?
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
      json["linked_document"] = self.linked_document_data
    end
    #puts json
    json
  end

  # temp method for spr 2022 overhaul
  # return the value of json that would be in legacy custom_data field on response set for this answer's question
  def custom_data_json
    return {"#{self.question.json_key}": self.raw_value}
  end
end
