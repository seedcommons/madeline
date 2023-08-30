class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|
      t.references :response_set, index: true, foreign_key: true, null: false
      t.references :question, index: true, foreign_key: true, null: false
      t.boolean :not_applicable, null: false, default: false
      t.string :text_data
      t.string :numeric_data
      t.boolean :boolean_data
      t.json :linked_document_data
      t.json :business_canvas_data
      t.json :breakeven_data
      t.timestamps
    end
    add_index :answers, %i[response_set_id question_id], unique: true
  end
end
