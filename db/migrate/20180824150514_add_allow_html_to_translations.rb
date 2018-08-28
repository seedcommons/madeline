class AddAllowHtmlToTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :translations, :allow_html, :boolean, default: false
  end
end
