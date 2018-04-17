class RenameLoanResponseSet < ActiveRecord::Migration[5.1]
  def change
    rename_table :loan_response_sets, :response_sets
  end
end
