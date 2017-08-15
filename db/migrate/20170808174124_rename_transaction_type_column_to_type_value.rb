class RenameTransactionTypeColumnToTypeValue < ActiveRecord::Migration
  def change
    rename_column :accounting_transactions, :loan_transaction_type, :loan_transaction_type_value
  end
end
