class CreateDivisions < ActiveRecord::Migration
  def change
    create_table :divisions do |t|
      t.references :organization, index: true, foreign_key: true
      t.string :name
      t.text :description
      t.integer :parent_id
      t.references :currency, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
