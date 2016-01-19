class CreateOptionSets < ActiveRecord::Migration
  def change
    create_table :option_sets do |t|
      t.references :division, index: true, null: false, foreign_key: true
      t.string :model_type
      t.string :model_attribute

      t.timestamps null: false
    end
  end
end
