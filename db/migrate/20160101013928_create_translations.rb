class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.references :translatable, polymorphic: true, index: true
      t.string :translatable_attribute
      t.references :language, index: true
      t.text :text
      # defer these fields until need is more clear
      # t.boolean :is_primary
      # t.boolean :is_dirty

      t.timestamps
    end
  end
end
