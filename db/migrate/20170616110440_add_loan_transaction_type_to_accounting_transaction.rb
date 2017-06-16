class AddLoanTransactionTypeToAccountingTransaction < ActiveRecord::Migration
  def change
    add_column :accounting_transactions, :loan_transaction_type, :string
  end
end
