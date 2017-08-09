class RemoveQbIdNullFromAccountingTransaction < ActiveRecord::Migration
  def change
    change_column :accounting_transactions, :qb_id, :string, null: true
  end
end
