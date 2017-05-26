class AddUpdatedByToResponseSets < ActiveRecord::Migration
  def change
    add_column :loan_response_sets, :updater_id, :integer
    add_foreign_key :loan_response_sets, :users, column: :updater_id
  end
end
