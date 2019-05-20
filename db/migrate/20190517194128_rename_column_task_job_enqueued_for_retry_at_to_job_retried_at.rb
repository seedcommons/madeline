class RenameColumnTaskJobEnqueuedForRetryAtToJobRetriedAt < ActiveRecord::Migration[5.2]
  def change
    rename_column :tasks, :job_enqueued_for_retry_at, :job_retried_at
    add_column :tasks, :job_last_started_at, :datetime
  end
end
