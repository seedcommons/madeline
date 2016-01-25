class AddCustomModelRefsToLoans < ActiveRecord::Migration
  def change
    add_reference :loans, :loan_criteria
    add_reference :loans, :post_analysis
    add_foreign_key :loans, :custom_models, column: :loan_criteria_id
    add_foreign_key :loans, :custom_models, column: :post_analysis_id
  end
end
