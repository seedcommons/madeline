class AddFinalizedAtToProjectSteps < ActiveRecord::Migration

  def up
    add_column :project_steps, :finalized_at, :datetime

    execute "UPDATE project_steps SET finalized_at = updated_at WHERE project_steps.is_finalized = 't' AND project_steps.finalized_at IS NULL"
  end

  def down
    remove_column :project_steps, :finalized_at, :datetime
  end

end
