class CreateAccountingCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :accounting_customers do |t|
      t.string :qb_id, null: false
      t.string :name, null: false
      t.json :quickbooks_data
      t.timestamps
    end
  end
end
