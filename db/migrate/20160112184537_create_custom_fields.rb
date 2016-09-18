class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :loan_questions do |t|
      t.references :loan_question_set, index: true, foreign_key: true
      t.string :internal_name
      t.string :label
      t.string :data_type
      t.integer :position
      #todo: add foreign key once migration stabilized, consider need for index after implementation complete
      t.references :parent, references: :loan_questions

      t.timestamps null: false
    end
  end
end
