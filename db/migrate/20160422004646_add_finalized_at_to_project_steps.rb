class AddFinalizedAtToProjectSteps < ActiveRecord::Migration

  def up
    add_column :project_steps, :finalized_at, :datetime
    ProjectStep.where(is_finalized: true, finalized_at: nil).update_all("finalized_at = updated_at")
  end

  def down
    remove_column :project_steps, :finalized_at, :datetime
  end

end
