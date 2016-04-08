class AddCustomDataToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :custom_data, :json
  end
end
