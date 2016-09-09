class AdjustAmountField < ActiveRecord::Migration
  def change
    change_column_null :custom_field_requirements, :amount, true
    change_column_default :custom_field_requirements, :amount, nil
    CustomFieldRequirement.update_all(amount: nil)
  end
end
