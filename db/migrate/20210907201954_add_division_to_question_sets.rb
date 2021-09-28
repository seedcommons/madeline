class AddDivisionToQuestionSets < ActiveRecord::Migration[6.1]
  def up
    add_reference :question_sets, :division, foreign_key: true, index: true
    QuestionSet.update_all(division_id: Division.root.id)
    change_column_null :question_sets, :division_id, false
  end

  def down
    change_column_null :question_sets, :division_id, true
    remove_reference :question_sets, :division
  end
end
