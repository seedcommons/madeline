class AddLoanFields < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :projected_first_payment_date, :date
    add_column :projects, :actual_first_interest_payment_date, :date
    add_column :projects, :actual_end_date, :date
    add_column :projects, :actual_return, :decimal
  end
end
