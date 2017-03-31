class CreateLoanHealthChecks < ActiveRecord::Migration
  def change
    create_table :loan_health_checks do |t|
      t.references :loan, index: true, references: :project
      t.boolean :missing_contract
      t.decimal :progress_pct
      t.date :last_log_date
      t.boolean :has_late_steps
      t.boolean :has_sporadic_updates

      t.timestamps null: false
    end

    add_foreign_key :loan_health_checks, :projects, column: :loan_id
  end
end
