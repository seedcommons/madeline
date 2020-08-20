class AddAccountingQbDepartmentToDivision < ActiveRecord::Migration[5.2]
  def change
    add_reference :divisions, :accounting_qb_department, foreign_key: true
  end
end
