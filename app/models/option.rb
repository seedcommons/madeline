class Option < ApplicationRecord
  include Translatable

  belongs_to :option_set

  # Used for Questions to LoanTypes(Options) associations which imply a required
  # question for a given loan type.
  has_many :loan_question_requirements, dependent: :destroy
  has_many :questions, through: :loan_question_requirements

  delegate :division, :division=, to: :option_set

  # define accessor like convenience methods for the fields stored in the Translations table
  translates :label, :description

  after_create :ensure_value_assigned

  def ensure_value_assigned
    unless value
      self.update_column(:value, self.id)
    end
  end

end
