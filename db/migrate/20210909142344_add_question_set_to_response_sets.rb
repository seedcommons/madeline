class AddQuestionSetToResponseSets < ActiveRecord::Migration[6.1]
  def up
    add_reference :response_sets, :question_set, foreign_key: true, index: true
    execute("UPDATE response_sets SET question_set_id = "\
      "(SELECT id FROM question_sets WHERE kind = response_sets.kind)")
    change_column_null :response_sets, :question_set_id, false
  end

  def down
    change_column_null :response_sets, :question_set_id, true
    remove_reference :response_sets, :question_set
  end
end
