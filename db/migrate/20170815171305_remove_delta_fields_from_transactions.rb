class RemoveDeltaFieldsFromTransactions < ActiveRecord::Migration
  def change
    remove_column :accounting_transactions, :change_in_interest
    remove_column :accounting_transactions, :change_in_principal
  end
end
