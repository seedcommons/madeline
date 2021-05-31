class RenameLoanIssues < ActiveRecord::Migration[5.2]
  def change
    rename_table :accounting_loan_issues, :accounting_sync_issues
  end
end
