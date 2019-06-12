class DropDelayedJobsTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :delayed_jobs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
