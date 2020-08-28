class AddDivisionToAccountingQbDepartments < ActiveRecord::Migration[5.2]
  def change
    add_reference :accounting_qb_departments, :division, foreign_key: true
  end
end
