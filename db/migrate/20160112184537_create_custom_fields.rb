class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.references :custom_field_set, index: true, foreign_key: true
      t.string :internal_name
      t.string :label
      t.string :data_type
      t.integer :position
      t.references :parent, references: :custom_fields

      t.timestamps null: false
    end
  end
end
