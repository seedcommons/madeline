class AddAccessTokenRefreshTokenToAccountingQuickbooksConnection < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_quickbooks_connections, :access_token, :string
    add_column :accounting_quickbooks_connections, :refresh_token, :string
  end
end
