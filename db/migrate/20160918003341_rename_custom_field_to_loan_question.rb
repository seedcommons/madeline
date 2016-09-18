class RenameCustomFieldToLoanQuestion < ActiveRecord::Migration
  def change
    rename_table :loan_questions, :loan_questions
    rename_table :loan_question_sets, :loan_question_sets
    rename_table :loan_question_requirements, :loan_question_requirements
  end
end
