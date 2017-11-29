class RemoveDefaultFromDuration < ActiveRecord::Migration
  def change
    change_column_default(:timeline_entries, :scheduled_duration_days, nil)
    execute("UPDATE timeline_entries SET scheduled_duration_days = null WHERE scheduled_duration_days < 1")
  end
end
