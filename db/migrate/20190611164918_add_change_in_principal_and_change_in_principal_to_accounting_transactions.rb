class AddChangeInPrincipalAndChangeInPrincipalToAccountingTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_transactions, :change_in_principal, :decimal, precision: 15, scale: 2
    add_column :accounting_transactions, :change_in_interest, :decimal, precision: 15, scale: 2
  end
end
