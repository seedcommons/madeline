class RequireCurrencyOnLoan < ActiveRecord::Migration
  def change
    change_column :loans, :currency_id, :integer, null: false
  end
end
