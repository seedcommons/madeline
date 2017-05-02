class AddNotNullConstraintToProjectStepValue < ActiveRecord::Migration
  def up
    execute("UPDATE timeline_entries SET step_type_value = 'group' WHERE type = 'ProjectGroup'")
    execute("UPDATE timeline_entries SET step_type_value = 'checkin'
      WHERE step_type_value = '' OR step_type_value IS NULL")
    change_column_null :timeline_entries, :step_type_value, false
  end
end
``
