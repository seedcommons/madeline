class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|
      t.references :response_set, index: true, foreign_key: true
      t.references :question, index: true, foreign_key: true
      t.boolean :not_applicable, null: false, default: false
      t.string :text_data
      t.string :numeric_data
      t.boolean :boolean_data
      t.json :linked_document_data
      t.json :business_canvas_data
      t.json :breakeven_data
      t.timestamps
    end
  end
end
