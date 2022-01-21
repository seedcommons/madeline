class AddFieldsToOrganization < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :entity_structure, :string, default: 'not_selected', null: false
    add_column :organizations, :date_established, :date, null: true
    add_column :organizations, :census_track_code, :string, null: true
    add_column :organizations, :naics_code, :string, null: true
  end
end
