class RemoveProjectTypeValueFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :project_type_value, :string
  end
end
