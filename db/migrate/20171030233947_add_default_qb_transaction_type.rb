class AddDefaultQbTransactionType < ActiveRecord::Migration
  def change
    change_column_default :accounting_transactions, :qb_transaction_type, 'JournalEntry'
  end
end
