class CreateProjectLogs < ActiveRecord::Migration
  def change
    create_table :project_logs do |t|
      t.references :project_step, index: true
      t.references :person, index: true
      t.integer :progress_metric_option_id
      t.date :date

      t.timestamps
    end
  end
end
