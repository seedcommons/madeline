class AddPostalCodeToPeopleAndOrganizations < ActiveRecord::Migration
  def change
    add_column :people, :postal_code, :string
    add_column :organizations, :postal_code, :string
  end
end
