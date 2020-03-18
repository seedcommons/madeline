class AddTxnsReadOnlyToLoan < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :txns_read_only, :boolean, null: false, default: false
  end
end
