class CreateLoanTypeQuestions < ActiveRecord::Migration
  def change
    create_table :loan_type_questions do |t|
      t.references :division, index: true, foreign_key: true
      t.references :loan_type, references: :option, index: true
      t.references :question, references: :custom_field, index: true
      # Todo: Confirm if we want a 'status' field which which could represent other possible
      # values like 'hidden', or a single purpose boolean field.
#      t.string :status     # values: 'required', ?'hidden'
      t.boolean :required, default: false, null: false
      t.timestamps null: false
    end
    add_foreign_key :loan_type_questions, :options, column: :loan_type_id
    add_foreign_key :loan_type_questions, :custom_fields, column: :question_id
  end
end
