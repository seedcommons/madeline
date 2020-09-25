class AddCheckFieldsToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_transactions, :check_number, :string
    add_column :accounting_transactions, :qb_vendor_id, :integer, references: :accounting_qb_vendors
    add_column :accounting_transactions, :qb_object_subtype, :string
  end
end
