class AddLocaleToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :locale, :string
  end
end
