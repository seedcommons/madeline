class AddErrorMessageToAccountingProblemLoanTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_problem_loan_transactions, :error_message, :string
  end
end
