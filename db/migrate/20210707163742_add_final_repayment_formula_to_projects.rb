class AddFinalRepaymentFormulaToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :final_repayment_formula, :text
  end
end
