class AddBalancesToTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :accounting_transactions, :principal_balance, :decimal, default: 0.0
    add_column :accounting_transactions, :interest_balance, :decimal, default: 0.0
    add_column :accounting_transactions, :change_in_interest, :decimal, default: 0.0
    add_column :accounting_transactions, :change_in_principal, :decimal, default: 0.0
  end
end
