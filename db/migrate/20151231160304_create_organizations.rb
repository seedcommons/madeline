class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :display_name
      t.string :sector
      t.string :industry
      t.string :referral_source
      t.float :woman_ownership_percent
      t.float :poc_ownership_percent
      t.integer :environmental_impact_score

      t.timestamps null: false
    end
  end
end
