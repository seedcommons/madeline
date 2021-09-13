class AddResponseSetsLoansForeignKey < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute("DELETE FROM response_sets WHERE NOT EXISTS "\
          "(SELECT id FROM projects WHERE loan_id = projects.id)")
      end
    end
    add_foreign_key :response_sets, :projects, column: :loan_id
  end
end
