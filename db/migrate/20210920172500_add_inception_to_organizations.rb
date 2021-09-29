class AddInceptionToOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :inception_value, :string
  end
end
