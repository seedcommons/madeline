class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :iso_code, limit: 2
      t.references :default_currency, references: :currencies

      t.timestamps null: false
    end

    add_foreign_key :countries, :currencies, column: :default_currency_id
  end
end
