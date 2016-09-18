class CreateCustomValueSets < ActiveRecord::Migration
  def change
    create_table :custom_value_sets do |t|
      # note, the default polymorphic index name was too long
      t.references :custom_value_set_linkable, polymorphic: true, null: false, index: { name: 'custom_value_sets_on_linkable' }
      t.references :loan_question_set, index: true, null: false, foreign_key: true
      t.json :custom_data

      t.timestamps null: false
    end
  end
end
