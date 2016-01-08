class CreateProjectLogs < ActiveRecord::Migration
  def change
    create_table :project_logs do |t|
      t.references :project_step, index: true
      t.references :agent, index: true
      t.integer :progress_metric_option_id
      t.date :date

      t.timestamps null: false
    end
    add_foreign_key :project_logs, :people, column: :agent_id
  end
end
