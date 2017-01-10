class RenameLoansToProjects < ActiveRecord::Migration
  def up
    rename_table :loans, :projects

    add_column :projects, :type, :string, index: true

    execute "UPDATE projects SET type = 'Loan'"
    execute "UPDATE translations SET translatable_type = 'Project' WHERE translatable_type = 'Loan'"
    execute "UPDATE timeline_entries SET project_type = 'Project' WHERE project_type = 'Loan'"

    change_column_null :projects, :type, false
  end

  def down
    execute "UPDATE projects SET type = 'Loan'"
    execute "UPDATE translations SET translatable_type = 'Loan' WHERE translatable_type = 'Project'"
    execute "UPDATE timeline_entries SET project_type = 'Loan' WHERE project_type = 'Project'"

    remove_column :projects, :type

    rename_table :projects, :loans
  end
end
