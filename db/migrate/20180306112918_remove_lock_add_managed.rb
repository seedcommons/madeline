class RemoveLockAddManaged < ActiveRecord::Migration[5.1]
  def change
    remove_column :accounting_transactions, :locked
    add_column :accounting_transactions, :managed, :boolean, default: false, null: false
  end
end
