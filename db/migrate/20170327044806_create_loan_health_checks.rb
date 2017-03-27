class CreateLoanHealthChecks < ActiveRecord::Migration
  def change
    create_table :loan_health_checks do |t|
      t.references :project, index: true, foreign_key: true
      t.boolean :missing_contract
      t.decimal :progress_pct
      t.date :last_log_date
      t.boolean :has_late_steps
      t.boolean :has_sporadic_updates

      t.timestamps null: false
    end
  end
end
