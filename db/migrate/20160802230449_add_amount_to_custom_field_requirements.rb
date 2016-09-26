class AddAmountToCustomFieldRequirements < ActiveRecord::Migration
  def change
    add_column :custom_field_requirements, :amount, :decimal, default: 0, null: false
  end
end
