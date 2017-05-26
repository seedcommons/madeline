class AddLockVersionToLoanResponseSets < ActiveRecord::Migration
  def change
    add_column :loan_response_sets, :lock_version, :integer
  end
end
