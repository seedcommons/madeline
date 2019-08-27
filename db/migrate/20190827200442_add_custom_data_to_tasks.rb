class AddCustomDataToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :custom_data, :json
  end
end
