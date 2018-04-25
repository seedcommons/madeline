class RenameLoanQuestionHierarchies < ActiveRecord::Migration[5.1]
  def change
    rename_table :loan_question_hierarchies, :question_hierarchies
  end
end
