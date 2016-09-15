class ChangeScheduledDateToScheduledStartDate < ActiveRecord::Migration
  def change
    rename_column :timeline_entries, :scheduled_date, :scheduled_start_date

    add_column :timeline_entries, :scheduled_duration_days, :integer, default: 0

    add_column :timeline_entries, :schedule_ancestor_id, :integer, index: true
    add_foreign_key :timeline_entries, :timeline_entries, column: :schedule_ancestor_id
  end
end
