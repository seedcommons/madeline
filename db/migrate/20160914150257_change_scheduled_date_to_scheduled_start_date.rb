class ChangeScheduledDateToScheduledStartDate < ActiveRecord::Migration
  def change
    rename_column :timeline_entries, :scheduled_date, :scheduled_start_date
  end
end
