class RenameQuickbooksNamespaceToQb < ActiveRecord::Migration[5.2]
  def change
    rename_table :accounting_quickbooks_connections, :accounting_qb_connections
  end
end
