class RemoveLanguageIdFromTranslations < ActiveRecord::Migration
  def change
    remove_column :translations, :language_id, :integer
  end
end
