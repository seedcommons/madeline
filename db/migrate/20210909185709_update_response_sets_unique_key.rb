class UpdateResponseSetsUniqueKey < ActiveRecord::Migration[6.1]
  def change
    add_index :response_sets, %i[loan_id question_set_id], unique: true
    remove_index :response_sets, %i[loan_id kind], unique: true
  end
end
