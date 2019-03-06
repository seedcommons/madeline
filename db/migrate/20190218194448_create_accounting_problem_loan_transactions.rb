class CreateAccountingProblemLoanTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :accounting_problem_loan_transactions do |t|
      t.references :project, foreign_key: true
      t.references :accounting_transaction, foreign_key: true, index: { name: :index_plt_on_txn_id }

      t.timestamps
    end
  end
end
