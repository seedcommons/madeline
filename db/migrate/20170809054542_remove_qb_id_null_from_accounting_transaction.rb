class RemoveQbIdNullFromAccountingTransaction < ActiveRecord::Migration
  def change
    change_column_null :accounting_transactions, :qb_id, true
  end
end
