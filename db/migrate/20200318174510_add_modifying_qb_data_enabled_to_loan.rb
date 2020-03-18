class AddModifyingQbDataEnabledToLoan < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :modifying_qb_data_enabled, :boolean, default: :true
  end
end
