class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :job_class, limit: 255, null: false
      t.string :provider_job_id # unknown at creation
      t.string :job_type_value, null: false, limit: 255
      t.string :activity_message_value, null: false, limit:  64.kilobytes # may have backtraces
      t.datetime :job_first_started_at
      t.datetime :job_last_failed_at
      t.datetime :job_enqueued_for_retry_at
      t.datetime :job_succeeded_at
      t.integer :num_attempts, null: false, default: 0
    end
  end
end
