class AddDateChangeCountToProjectStep < ActiveRecord::Migration
  def change
    add_column :project_steps, :date_change_count, :integer, default: 0, null: false
  end
end
