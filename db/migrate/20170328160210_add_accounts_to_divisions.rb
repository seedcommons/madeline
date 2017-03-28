class AddAccountsToDivisions < ActiveRecord::Migration
  def change
    add_reference :divisions, :principal_account, index: true
    add_foreign_key :divisions, :accounting_accounts, column: :principal_account_id
    add_reference :divisions, :interest_receivable_account, index: true
    add_foreign_key :divisions, :accounting_accounts, column: :interest_receivable_account_id
    add_reference :divisions, :interest_income_account, index: true
    add_foreign_key :divisions, :accounting_accounts, column: :interest_income_account_id
  end
end
