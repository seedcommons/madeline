# Used for Questions to LoanTypes(Options) associations which imply a required
# question for a given loan type.

class LoanQuestionRequirement < ApplicationRecord
  belongs_to :question
  #belongs_to :option
  belongs_to :loan_type, class_name: 'Option', foreign_key: :option_id
end
