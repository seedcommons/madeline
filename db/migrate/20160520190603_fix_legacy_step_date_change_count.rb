class FixLegacyStepDateChangeCount < ActiveRecord::Migration
  def up
    execute "UPDATE project_steps SET date_change_count = 1 WHERE project_steps.date_change_count = 0 AND project_steps.original_date IS NOT NULL"
  end
end
