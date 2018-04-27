class AddLoanTransactionTypeToAccountingTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :accounting_transactions, :loan_transaction_type, :string
  end
end
