class AddCurrencyToTransactions < ActiveRecord::Migration[4.2]
  def change
    add_reference :accounting_transactions, :currency, index: true, foreign_key: true
  end
end
