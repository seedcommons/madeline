class CreateAccountingTransactions < ActiveRecord::Migration
  def change
    create_table :accounting_transactions do |t|
      t.string :qb_transaction_id, null: false
      t.string :qb_transaction_type, null: false

      t.timestamps null: false
    end
  end
end
