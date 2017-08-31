class RemoveLineItemTransactionConstraint < ActiveRecord::Migration
  def change
    # transactions being passed to the transaction creator are still new instances
    # without ids so the specs keep failing when trying to associate a line item

    change_column_null :accounting_line_items, :accounting_transaction_id, true
  end
end
