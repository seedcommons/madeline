class AddDivisionToQuestionSets < ActiveRecord::Migration[6.1]
  def change
    add_reference :question_sets, :division, foreign_key: true, index: true
    reversible do |dir|
      dir.up do
        QuestionSet.update_all(division_id: Division.root.id)
      end
    end
    change_column_null :question_sets, :division_id, false
  end
end
