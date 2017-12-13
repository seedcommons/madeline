class AddNotNullToDivisionOnProjects < ActiveRecord::Migration[4.2]
  def change
    change_column_null :projects, :division_id, false
  end
end
