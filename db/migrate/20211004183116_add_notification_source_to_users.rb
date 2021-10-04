class AddNotificationSourceToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :notification_source, :string, null: false, default: "home_only"
  end
end
