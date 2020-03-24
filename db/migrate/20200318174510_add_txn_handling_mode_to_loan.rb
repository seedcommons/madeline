class AddTxnHandlingModeToLoan < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :txn_handling_mode, :string, null: false, default: 'automatic'
  end
end
