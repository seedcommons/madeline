class AddLanguageToCountries < ActiveRecord::Migration
  def change
    add_reference :countries, :language, index: true, foreign_key: true
  end
end
