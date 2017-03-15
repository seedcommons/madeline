class AddAccountingAccountRefToAccountingTransaction < ActiveRecord::Migration
  def change
    add_reference :accounting_transactions, :accounting_account, index: true, foreign_key: true
    add_reference :accounting_transactions, :project, index: true, foreign_key: true
    add_column :accounting_transactions, :quickbooks_data, :json
    rename_column :accounting_transactions, :qb_transaction_id, :qb_id
  end
end
