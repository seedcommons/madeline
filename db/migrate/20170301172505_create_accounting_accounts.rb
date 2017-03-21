class CreateAccountingAccounts < ActiveRecord::Migration
  def change
    create_table :accounting_accounts do |t|
      t.string :name, null: false
      t.string :qb_account_classification, unique: true
      t.string :qb_id, null: false, index: true, unique: true
      t.json :quickbooks_data

      t.timestamps null: false
    end
  end
end
