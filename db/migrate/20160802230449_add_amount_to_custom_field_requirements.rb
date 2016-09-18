class AddAmountToCustomFieldRequirements < ActiveRecord::Migration
  def change
    add_column :loan_question_requirements, :amount, :decimal, default: 0, null: false
  end
end
