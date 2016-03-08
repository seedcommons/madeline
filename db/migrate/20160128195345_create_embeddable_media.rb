class CreateEmbeddableMedia < ActiveRecord::Migration
  def change
    create_table :embeddable_media do |t|
      t.string :url
      t.string :original_url
      t.integer :height
      t.integer :width
      t.text :html

      t.timestamps null: false
    end
  end
end
