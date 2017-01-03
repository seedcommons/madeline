class ChangeOriginalDateToOldStartDate < ActiveRecord::Migration
  def change
    rename_column :timeline_entries, :original_date, :old_start_date
    rename_column :timeline_entries, :completed_date, :actual_end_date

    add_column :timeline_entries, :old_duration_days, :integer, default: 0
  end
end
