class AddIsRecoveredToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :is_recovered, :boolean
  end
end
