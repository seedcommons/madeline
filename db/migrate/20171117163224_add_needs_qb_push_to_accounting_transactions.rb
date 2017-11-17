class AddNeedsQbPushToAccountingTransactions < ActiveRecord::Migration
  def change
    add_column :accounting_transactions, :needs_qb_push, :boolean, null: false, default: true
  end
end
