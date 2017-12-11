class RemoveDivisionIdFromLoanQuestionSets < ActiveRecord::Migration[4.2]
  def change
    remove_column :loan_question_sets, :division_id, :integer
  end
end
