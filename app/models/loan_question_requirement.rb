# == Schema Information
#
# Table name: loan_question_requirements
#
#  amount      :decimal(, )
#  id          :integer          not null, primary key
#  option_id   :integer
#  question_id :integer
#

# Used for Questions to LoanTypes(Options) associations which imply a required
# question for a given loan type.

class LoanQuestionRequirement < ApplicationRecord
  belongs_to :question
  #belongs_to :option
  belongs_to :loan_type, class_name: 'Option', foreign_key: :option_id
end
