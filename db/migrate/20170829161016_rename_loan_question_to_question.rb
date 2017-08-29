class RenameLoanQuestionToQuestion < ActiveRecord::Migration
  def change
    rename_table :loan_questions, :questions
  end
end
