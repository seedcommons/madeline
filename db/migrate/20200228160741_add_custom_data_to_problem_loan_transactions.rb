class AddCustomDataToProblemLoanTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_problem_loan_transactions, :custom_data, :json
  end
end
