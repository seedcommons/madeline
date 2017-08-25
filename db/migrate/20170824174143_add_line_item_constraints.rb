class AddLineItemConstraints < ActiveRecord::Migration
  def change
    change_column_null :accounting_line_items, :accounting_account_id, false
    change_column_null :accounting_line_items, :accounting_transaction_id, false
    change_column_null :accounting_line_items, :amount, false
    change_column_null :accounting_line_items, :posting_type, false
  end
end
