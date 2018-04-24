class RenameColumnLoanQuestionSet < ActiveRecord::Migration[5.1]
  def change
    rename_column :questions, :loan_question_set_id, :question_set_id
  end
end
