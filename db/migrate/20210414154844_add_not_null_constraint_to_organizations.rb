class AddNotNullConstraintToOrganizations < ActiveRecord::Migration[5.2]
  def change
    change_column_null :organizations, :country_id, false
  end
end
