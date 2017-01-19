class ChangeTargetEndDateToEndDateOnProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :target_end_date, :end_date
  end
end
