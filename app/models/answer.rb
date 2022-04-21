class Answer < ApplicationRecord
  belongs_to :response_set
  belongs_to :question
  delegate :data_type, to: :question

  with_options if: ->(answer) { answer&.question&.data_type == "boolean" } do |boolean_answer|
    boolean_answer.validates :boolean_data, presence: true
  end
  with_options if: ->(answer) { %w(rating range currency number percentage).include?(answer&.question&.data_type)  } do |numeric_answer|
    numeric_answer.validates :numeric_data, presence: true
  end
  with_options if: ->(answer) { %w(range text).include?(answer&.question&.data_type)  } do |text_answer|
    text_answer.validates :text_data, presence: true
  end
  with_options if: ->(answer) { %w(range text).include?(answer&.question&.data_type)  } do |text_answer|
    text_answer.validates :text_data, presence: true
  end
  validate :question_is_not_group

  # this method is temporary for spr 2022 overhaul
  def self.create_from_form_field_params(q_internal_name, fields, response_set)
    q = Question.find_by(internal_name: q_internal_name)
    not_applicable = fields.key?("not_applicable")  ? (fields["not_applicable"] == "yes") : nil
    text_data = fields.key?("text") ? fields["text"] : nil
    numeric_data = fields.key?("number") ? fields["number"] : nil
    boolean_data = field.key?("boolean") ? (fields["boolean"] == "yes") : nil
    breakeven_data = fields.key?("breakeven") ? fields["breakeven"] : nil
    business_canvas_data = fields.key?("business_canvas") ? fields["business_canvas"] : nil
    linked_document_data = fields.key?("url") ? {"url": fields["url"] } : nil
    linked_document_data["start_cell"] = fields["start_cell"] if fields.key("start_cell")
    linked_document_data["end_cell"] = fields["end_cell"] if fields.key("end_cell")
    Answer.create({
        response_set: response_set,
        question: q,
        not_applicable: not_applicable,
        text_data: text_data,
        numeric_data: numeric_data,
        boolean_data: boolean_data,
        breakeven_data: breakeven_data,
        business_canvas_data: business_canvas_data,
        linked_document_data: linked_document_data
      })
  end

  def question_is_not_group
    question.data_type != "group"
  end

  # return the value of json that would be in legacy custom_data field on response set for this answer's question
  def custom_data_json
    json = {}
    json["not_applicable"] = self.not_applicable
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
      json["number"] = self.numeric_data
    end
    if self.linked_document_data.present?
      json["linked_document"] = linked_document_data
    end
    return {"#{self.question.json_key}": json}
  end
end
