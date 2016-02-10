class AddLocaleToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :locale, :string
  end
end
