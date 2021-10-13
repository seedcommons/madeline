class RemoveNotifyOnNewLogsFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :notify_on_new_logs, :boolean
  end
end
