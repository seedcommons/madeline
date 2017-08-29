class RenameLoanQuestionSetToQuestionSet < ActiveRecord::Migration
  def change
    rename_table :loan_question_sets, :question_sets
  end
end
