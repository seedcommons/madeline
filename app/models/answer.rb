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
