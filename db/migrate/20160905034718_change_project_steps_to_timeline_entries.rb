class ChangeProjectStepsToTimelineEntries < ActiveRecord::Migration
  def change
    rename_table  :project_steps, :timeline_entries
    rename_column :project_logs,  :project_step_id, :timeline_entry_id

    add_column :timeline_entries, :type, :string

    reversible do
      execute "UPDATE timeline_entries SET type = 'ProjectStep'"
    end
  end
end
