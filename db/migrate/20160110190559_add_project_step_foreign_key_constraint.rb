class AddProjectStepForeignKeyConstraint < ActiveRecord::Migration
  def change
    # beware, this migration will fail if migrated data currently exists w/ invalid refs
    add_foreign_key :project_logs, :project_steps, column: :project_step_id
  end
end
