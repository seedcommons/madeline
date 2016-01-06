class CreateOrganizationSnapshots < ActiveRecord::Migration
  def change
    create_table :organization_snapshots do |t|
      # note, disabling this foreign key to ease migration handling.
      # todo: consider dropping all foreign keys until schema is stabilized
      t.references :organization, index: true, foreign_key: false
      t.date :date
      t.integer :organization_size
      t.integer :women_ownership_percent
      t.integer :poc_ownership_percent
      t.integer :environmental_impact_score

      t.timestamps
    end

  end
end
