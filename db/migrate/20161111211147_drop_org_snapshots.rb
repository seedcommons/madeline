class DropOrgSnapshots < ActiveRecord::Migration
  def change
    drop_table :organization_snapshots
    remove_column :loans, :organization_snapshot_id
    remove_column :organizations, :organization_snapshot_id
  end
end
