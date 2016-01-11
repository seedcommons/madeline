class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.references :option_set, index: true, foreign_key: true
      t.integer :position
      t.integer :value

      t.timestamps null: false
    end
  end
end
