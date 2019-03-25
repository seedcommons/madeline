class RequireErrorMessageForProblemLoanTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:accounting_problem_loan_transactions, :error_message, false)
  end
end
