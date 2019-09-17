class AddActivityMessageDataToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :activity_message_data, :json
  end
end
