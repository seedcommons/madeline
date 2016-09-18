class CreateCustomFieldSets < ActiveRecord::Migration
  def change
    create_table :loan_question_sets do |t|
      t.references :division, index: true, foreign_key: true
      t.string :internal_name

      t.timestamps null: false
    end
  end
end
