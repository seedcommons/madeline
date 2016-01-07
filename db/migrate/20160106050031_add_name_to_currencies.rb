class AddNameToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :name, :string
  end
end
