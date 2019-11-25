class RemoveSecretTokenFromAccountingQuickbooksConnections < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounting_quickbooks_connections, :secret, :string
    remove_column :accounting_quickbooks_connections, :token, :string
  end
end
