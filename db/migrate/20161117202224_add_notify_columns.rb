class AddNotifyColumns < ActiveRecord::Migration
  def change
    add_column :divisions, :notify_on_new_logs, :boolean, default: false
    add_column :users, :notify_on_new_logs, :boolean, default: true
  end
end
