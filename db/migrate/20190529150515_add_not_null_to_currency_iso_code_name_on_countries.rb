class AddNotNullToCurrencyIsoCodeNameOnCountries < ActiveRecord::Migration[5.2]
  def change
    change_column_null :countries, :default_currency_id, false
    change_column_null :countries, :iso_code, false
    change_column_null :countries, :name, false
  end
end
