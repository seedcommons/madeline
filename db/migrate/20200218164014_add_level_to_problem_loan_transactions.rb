class AddLevelToProblemLoanTransactions < ActiveRecord::Migration[5.2]
  def change
    rename_column :accounting_problem_loan_transactions, :error_message, :message
    add_column :accounting_problem_loan_transactions, :level, :string
  end
end
