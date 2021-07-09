class ChangeQbObjectSubtypeToDisbursementTypeOnTransaction < ActiveRecord::Migration[5.2]
  def up
    Accounting::Transaction.where(qb_object_subtype: "Cash").update_all(qb_object_subtype: :other)
    Accounting::Transaction.where(qb_object_subtype: "Check").update_all(qb_object_subtype: :check)
    rename_column :accounting_transactions, :qb_object_subtype, :disbursement_type
    change_column_default :accounting_transactions, :disbursement_type, :other
  end

  def down
    Accounting::Transaction.where(disbursement_type: :other).update_all(disbursement_type: "Cash")
    Accounting::Transaction.where(disbursement_type: :check).update_all(disbursement_type: "Check")
    rename_column :accounting_transactions, :disbursement_type, :qb_object_subtype
    change_column_default :accounting_transactions, :qb_object_subtype, :nil
  end
end
