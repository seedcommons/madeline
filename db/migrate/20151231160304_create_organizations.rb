class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :display_name
      t.string :sector
      t.string :industry
      t.string :referral_source

      t.timestamps null: false
    end
  end
end
