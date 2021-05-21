class AddInvalidGrantFlagToConnectionAndAddConstraints < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_qb_connections, :invalid_grant, :boolean, null: false, default: false
    remove_index :accounting_qb_connections, :division_id
    add_index :accounting_qb_connections, :division_id, unique: true
    change_column_null :accounting_qb_connections, :access_token, false
    change_column_null :accounting_qb_connections, :refresh_token, false
    change_column_null :accounting_qb_connections, :token_expires_at, false
    change_column_null :accounting_qb_connections, :division_id, false
    change_column_null :accounting_qb_connections, :realm_id, false
    change_column_null :accounting_qb_connections, :last_updated_at, false
  end
end
