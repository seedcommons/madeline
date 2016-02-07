class RemoveLanguages < ActiveRecord::Migration
  def change
    remove_foreign_key :countries, :languages
    remove_column :countries, :language_id
    remove_column :countries, :default_language_id
    drop_table :languages
  end
end
