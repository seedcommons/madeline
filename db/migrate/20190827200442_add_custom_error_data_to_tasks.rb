class AddCustomErrorDataToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :custom_error_data, :json
  end
end
