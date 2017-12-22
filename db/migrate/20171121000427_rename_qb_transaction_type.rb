class RenameQbTransactionType < ActiveRecord::Migration
  def change
    rename_column :accounting_transactions, :qb_transaction_type, :qb_object_type
  end
end
