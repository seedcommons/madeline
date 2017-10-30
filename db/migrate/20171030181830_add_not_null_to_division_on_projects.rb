class AddNotNullToDivisionOnProjects < ActiveRecord::Migration
  def change
    change_column_null :projects, :division_id, false
  end
end
