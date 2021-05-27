class RenameProblemLoanTxns < ActiveRecord::Migration[5.2]
  def change
    rename_table :accounting_problem_loan_transactions, :accounting_loan_issues
  end
end
