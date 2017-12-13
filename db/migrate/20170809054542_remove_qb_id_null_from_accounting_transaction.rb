class RemoveQbIdNullFromAccountingTransaction < ActiveRecord::Migration[4.2]
  def change
    change_column_null :accounting_transactions, :qb_id, true
  end
end
