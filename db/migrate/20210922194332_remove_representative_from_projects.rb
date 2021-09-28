class RemoveRepresentativeFromProjects < ActiveRecord::Migration[6.1]
  def change
    remove_reference(:projects, :representative, index: true, foreign_key: {to_table: :people})
  end
end
