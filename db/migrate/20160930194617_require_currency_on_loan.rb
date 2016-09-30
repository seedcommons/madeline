class Loan < ActiveRecord::Base; end

class RequireCurrencyOnLoan < ActiveRecord::Migration
  def up
    # Set nulls to USD (for development environments)
    Loan.where(currency_id: nil).update_all(currency_id: 2)
    change_column :loans, :currency_id, :integer, null: false
  end

  def down
    change_column :loans, :currency_id, :integer
  end
end
