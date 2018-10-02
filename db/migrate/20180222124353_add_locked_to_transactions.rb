class AddLockedToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :accounting_transactions, :locked, :boolean, default: true, null: false
  end
end
