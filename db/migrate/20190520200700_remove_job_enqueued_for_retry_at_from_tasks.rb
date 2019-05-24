class RemoveJobEnqueuedForRetryAtFromTasks < ActiveRecord::Migration[5.2]
  def change
    remove_column :tasks, :job_enqueued_for_retry_at, data_type: :datetime
  end
end
