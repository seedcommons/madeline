class RenameColumnLoanQuestionRequirement < ActiveRecord::Migration[5.1]
  def change
    rename_column :loan_question_requirements, :loan_question_id, :question_id
  end
end
