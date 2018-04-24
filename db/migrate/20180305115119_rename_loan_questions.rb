class RenameLoanQuestions < ActiveRecord::Migration[5.1]
  def change
    rename_table :loan_questions, :questions
  end
end
