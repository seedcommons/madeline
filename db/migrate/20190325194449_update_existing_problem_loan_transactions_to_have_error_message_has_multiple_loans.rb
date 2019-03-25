class UpdateExistingProblemLoanTransactionsToHaveErrorMessageHasMultipleLoans < ActiveRecord::Migration[5.2]
  def change
    execute "UPDATE accounting_problem_loan_transactions SET error_message = 'has_multiple_loans' WHERE error_message IS NULL;"
  end
end
