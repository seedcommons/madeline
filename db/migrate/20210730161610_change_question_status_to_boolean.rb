class ChangeQuestionStatusToBoolean < ActiveRecord::Migration[6.1]
  def up
    add_column :questions, :active, :boolean, null: false, default: true
    execute("UPDATE questions SET active = 'f' WHERE status = 'inactive'")
    remove_column :questions, :status
  end
end
