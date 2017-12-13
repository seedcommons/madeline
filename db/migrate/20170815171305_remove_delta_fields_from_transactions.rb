class RemoveDeltaFieldsFromTransactions < ActiveRecord::Migration[4.2]
  def change
    remove_column :accounting_transactions, :change_in_interest
    remove_column :accounting_transactions, :change_in_principal
  end
end
