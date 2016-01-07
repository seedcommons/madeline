class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.references :media_attachable, polymorphic: true, index: true
      t.integer :sort_order
      t.string :kind

      t.timestamps null: false
    end
  end
end
