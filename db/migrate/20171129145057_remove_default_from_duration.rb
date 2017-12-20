class RemoveDefaultFromDuration < ActiveRecord::Migration[4.2]
  def up
    change_column_default(:timeline_entries, :scheduled_duration_days, nil)
    execute("UPDATE timeline_entries SET scheduled_duration_days = null WHERE scheduled_duration_days < 1")
  end

  def down
    add_column :timeline_entries, :scheduled_duration_days, :integer, default: 0
  end
end
