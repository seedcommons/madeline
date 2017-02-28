class AddAccountingAccountRefToAccountingTransaction < ActiveRecord::Migration
  def change
    add_reference :accounting_transactions, :accounting_account, index: true, foreign_key: true, null: false
  end
end
