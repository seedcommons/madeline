class EnsureCorrectIndexNames < ActiveRecord::Migration[5.1]
  def up
    remove_index "accounting_transactions", ["qb_id", "qb_object_type"]
    remove_index "accounting_transactions", ["qb_object_type"]
    add_index "accounting_transactions", ["qb_id", "qb_object_type"], unique: true
    add_index "accounting_transactions", ["qb_object_type"]
  end
end
