class CreateProjectSteps < ActiveRecord::Migration
  def change
    create_table :project_steps do |t|
      t.references :project, polymorphic: true, index: true
      t.references :agent, index: true
      t.date :scheduled_date
      t.date :completed_date
      t.boolean :is_finalized
      t.integer :type_option_id

      t.timestamps null: false
    end
    add_foreign_key :project_steps, :people, column: :agent_id

  end
end
