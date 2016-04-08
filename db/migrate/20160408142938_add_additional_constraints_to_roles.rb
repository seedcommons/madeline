class AddAdditionalConstraintsToRoles < ActiveRecord::Migration
  def change
    change_column_null :roles, :name, false
    add_foreign_key :users_roles, :users
    add_foreign_key :users_roles, :roles

    remove_index :roles, column: [:name, :resource_type, :resource_id]
    add_index :roles, [:name, :resource_type, :resource_id], unique: true
    remove_index :users_roles, column:  [:user_id, :role_id]
    add_index :users_roles, [:user_id, :role_id], unique: true
  end
end
