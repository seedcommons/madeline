class AddCustomDataToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :custom_data, :json
  end
end
