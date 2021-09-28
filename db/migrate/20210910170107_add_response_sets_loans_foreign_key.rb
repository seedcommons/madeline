class AddResponseSetsLoansForeignKey < ActiveRecord::Migration[6.1]
  def up
    execute("DELETE FROM response_sets WHERE NOT EXISTS "\
      "(SELECT id FROM projects WHERE loan_id = projects.id)")
    add_foreign_key :response_sets, :projects, column: :loan_id
  end

  def down
    remove_foreign_key :response_sets, :projects
  end
end
