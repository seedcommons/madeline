class RemoveDivisionIdFromLoanQuestionSets < ActiveRecord::Migration
  def change
    remove_column :loan_question_sets, :division_id, :integer
  end
end
