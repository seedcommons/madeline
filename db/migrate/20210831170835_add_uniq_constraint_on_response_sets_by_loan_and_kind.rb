class AddUniqConstraintOnResponseSetsByLoanAndKind < ActiveRecord::Migration[6.1]
  def change
    add_index :response_sets, [:loan_id, :kind], unique: true
  end
end
