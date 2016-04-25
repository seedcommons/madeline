class AddCustomDataToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :custom_data, :json
  end
end
