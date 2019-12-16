class AddCustomerIdToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_transactions, :accounting_customer_id, :string, null: true
  end
end
