class AddNullFalseToQbConnections < ActiveRecord::Migration[4.2]
  def change
    change_column_null :accounting_quickbooks_connections, :division_id, false
    change_column_null :accounting_quickbooks_connections, :realm_id, false
    change_column_null :accounting_quickbooks_connections, :secret, false
    change_column_null :accounting_quickbooks_connections, :token, false
    change_column_null :accounting_quickbooks_connections, :token_expires_at, false 
  end
end
