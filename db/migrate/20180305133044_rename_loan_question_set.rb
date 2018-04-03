class RenameLoanQuestionSet < ActiveRecord::Migration[5.1]
  def change
    rename_table :loan_question_sets, :question_sets
  end
end
