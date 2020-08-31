class RemoveQbIdFromOrganizations < ActiveRecord::Migration[5.2]
  def up
    remove_column :organizations, :qb_id
  end

  def down
    add_column :organizations, :qb_id, :string
  end
end
