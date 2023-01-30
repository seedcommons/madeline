class EnsureDivisionNameUniq < ActiveRecord::Migration[6.1]
  def change
    add_index :divisions, :name, unique: true
    remove_column :divisions, :organization_id, :integer # as of Jan 30, 2023, nil for all divisions on prod
  end
end
