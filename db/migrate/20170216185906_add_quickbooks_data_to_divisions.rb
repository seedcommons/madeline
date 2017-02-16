class AddQuickbooksDataToDivisions < ActiveRecord::Migration
  def change
    add_column :divisions, :quickbooks_data, :json
  end
end
