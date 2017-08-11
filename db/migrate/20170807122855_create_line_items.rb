class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :accounting_line_items do |t|
      t.integer :qb_line_id
      t.references :accounting_transaction, index: true, foreign_key: true
      t.references :accounting_account, index: true, foreign_key: true
      t.string :posting_type
      t.string :description
      t.decimal :amount

      t.timestamps null: false
    end
  end
end
