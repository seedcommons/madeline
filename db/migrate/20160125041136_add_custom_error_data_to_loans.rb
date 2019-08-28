class AddCustomDataToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :custom_error_data, :json
  end
end
