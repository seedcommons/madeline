class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :code
      t.decimal :current_exchange_rate
      t.datetime :exchange_rate_date
      t.string :symbol
      t.string :short_symbol

      t.timestamps null: false
    end
  end
end
