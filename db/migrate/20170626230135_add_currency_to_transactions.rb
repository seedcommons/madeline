class AddCurrencyToTransactions < ActiveRecord::Migration
  def change
    add_reference :accounting_transactions, :currency, index: true, foreign_key: true
  end
end
