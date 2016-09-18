# == Schema Information
#
# Table name: loan_question_requirements
#
#  amount          :decimal(, )
#  loan_question_id :integer
#  id              :integer          not null, primary key
#  option_id       :integer
#

# Used for Questions(LoanQuestion) to LoanTypes(Options) associations which imply a required
# question for a given loan type.

class LoanQuestionRequirement < ActiveRecord::Base
  belongs_to :loan_question
  #belongs_to :option
  belongs_to :loan_type, class_name: 'Option', foreign_key: :option_id
end
