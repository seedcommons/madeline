class CreateProjectSteps < ActiveRecord::Migration
  def change
    create_table :project_steps do |t|
      t.references :project, polymorphic: true, index: true
      t.references :person, index: true
      t.date :scheduled_date
      t.date :completed_date
      t.boolean :is_finalized
      t.integer :type_option_id

      t.timestamps
    end
  end
end
