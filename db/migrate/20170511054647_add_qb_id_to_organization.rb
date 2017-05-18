class AddQbIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :qb_id, :string
  end
end
