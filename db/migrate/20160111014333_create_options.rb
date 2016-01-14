class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.references :option_set, index: true, foreign_key: true
      t.string :value
      t.integer :position
      t.integer :migration_id

      t.timestamps null: false
    end
  end
end
