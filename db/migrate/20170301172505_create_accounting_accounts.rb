class CreateAccountingAccounts < ActiveRecord::Migration
  def change
    create_table :accounting_accounts do |t|
      t.references :project, index: true, foreign_key: true
      t.string :name, null: false
      t.string :qb_account_id, null: false, index: true, unique: true

      t.timestamps null: false
    end
  end
end
