class AddDefaultQbTransactionType < ActiveRecord::Migration[4.2]
  def change
    change_column_default :accounting_transactions, :qb_transaction_type, 'JournalEntry'
  end
end
