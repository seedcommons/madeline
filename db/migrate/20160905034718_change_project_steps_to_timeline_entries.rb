class ChangeProjectStepsToTimelineEntries < ActiveRecord::Migration
  def change
    rename_table  :project_steps,    :timeline_entries

    add_column    :timeline_entries, :type,                :string
    add_column    :project_logs,     :timeline_entry_type, :string

    rename_column :project_logs,     :project_step_id,     :timeline_entry_id
  end
end
