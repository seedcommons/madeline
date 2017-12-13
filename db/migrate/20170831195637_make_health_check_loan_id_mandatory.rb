class MakeHealthCheckLoanIdMandatory < ActiveRecord::Migration[4.2]
  def change
    execute("DELETE FROM loan_health_checks WHERE loan_id IS NULL")
    change_column_null :loan_health_checks, :loan_id, false
  end
end
