class ChangeProjectStepsToTimelineEntries < ActiveRecord::Migration
  def change
    rename_table :project_steps, :timeline_entries

    add_column :timeline_entries, :type, :string, index: true

    execute "UPDATE timeline_entries SET type = 'ProjectStep'"
    execute "UPDATE translations SET translatable_type = 'TimelineEntry' WHERE translatable_type = 'ProjectStep'"

    change_column_null :timeline_entries, :type, false
  end
end
