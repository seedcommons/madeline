class AddDateChangedToToProjectLogs < ActiveRecord::Migration
  def change
    add_column :project_logs, :date_changed_to, :date
  end
end
