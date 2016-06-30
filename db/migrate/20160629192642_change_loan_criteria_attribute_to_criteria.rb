class ChangeLoanCriteriaAttributeToCriteria < ActiveRecord::Migration
  def up
    execute("UPDATE custom_value_sets SET linkable_attribute = 'criteria' WHERE linkable_attribute = 'loan_criteria'")
    execute("UPDATE custom_value_sets SET linkable_attribute = 'old_criteria' WHERE linkable_attribute = 'old_loan_criteria'")
  end
end
