class AddSyncTokenToAccountingTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_transactions, :sync_token, :string
  end
end
