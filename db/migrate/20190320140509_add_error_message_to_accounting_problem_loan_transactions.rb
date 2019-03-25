class AddErrorMessageToAccountingProblemLoanTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_problem_loan_transactions, :error_message, :string
    execute "UPDATE accounting_problem_loan_transactions SET error_message = 'has_multiple_loans' WHERE error_message IS NULL;"
    change_column_null(:accounting_problem_loan_transactions, :error_message, false)
  end
end
