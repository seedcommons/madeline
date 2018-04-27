class AddNeedsQbPushToAccountingTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :accounting_transactions, :needs_qb_push, :boolean, null: false, default: true
  end
end
