class RemoveCurrencyConstraint < ActiveRecord::Migration
  def change
    change_column :loans, :currency_id, :integer, null: true
  end
end
