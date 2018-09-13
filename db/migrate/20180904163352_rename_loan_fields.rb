class RenameLoanFields < ActiveRecord::Migration[5.1]
  def change
    rename_column :projects, :first_payment_date, :actual_first_payment_date
    rename_column :projects, :first_interest_payment_date, :projected_first_interest_payment_date
    rename_column :projects, :end_date, :projected_end_date
  end
end
