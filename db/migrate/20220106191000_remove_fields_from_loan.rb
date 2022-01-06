class RemoveFieldsFromLoan < ActiveRecord::Migration[6.1]
  def change
    remove_column :projects, :actual_return
    remove_column :projects, :projected_return
    remove_column :projects, :projected_first_interest_payment_date
    remove_column :projects, :actual_first_interest_payment_date
  end
end
