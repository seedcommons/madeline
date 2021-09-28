class AddLoanQuestionRequirementsForeignKey < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :loan_question_requirements, :questions
  end
end
