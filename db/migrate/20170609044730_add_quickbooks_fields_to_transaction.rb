class AddQuickbooksFieldsToTransaction < ActiveRecord::Migration
  def change
    add_column :accounting_transactions, :amount, :decimal
    add_column :accounting_transactions, :txn_date, :date
    add_column :accounting_transactions, :total, :decimal
    add_column :accounting_transactions, :private_note, :string
    add_column :accounting_transactions, :description, :string
  end
end
