class AddQuestionSetToResponseSets < ActiveRecord::Migration[6.1]
  def change
    add_reference :response_sets, :question_set, foreign_key: true, index: true
    reversible do |dir|
      dir.up do
        execute("UPDATE response_sets SET question_set_id = "\
          "(SELECT id FROM question_sets WHERE kind = response_sets.kind)")
      end
    end
    change_column_null :response_sets, :question_set_id, false
  end
end
