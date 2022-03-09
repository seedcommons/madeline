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
end
