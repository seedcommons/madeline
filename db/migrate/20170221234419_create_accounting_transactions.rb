class CreateAccountingTransactions < ActiveRecord::Migration
  def change
    create_table :accounting_transactions do |t|
      t.string :qb_transaction_id, null: false, index: true
      t.string :qb_transaction_type, null: false, index: true

      t.timestamps null: false
    end

    add_index :accounting_transactions, [:qb_transaction_id, :qb_transaction_type],
      unique: true,
      name: 'acc_trans_qbid_qbtype_unq_idx'
  end
end
