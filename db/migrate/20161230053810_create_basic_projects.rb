class CreateBasicProjects < ActiveRecord::Migration
  def change
    create_table :basic_projects do |t|
      t.references :division, index: true, foreign_key: true
      t.string :status_value
      t.references :primary_agent, references: :people, index: true
      t.references :secondary_agent, references: :people, index: true
      t.date :start_date
      t.date :target_end_date
      t.string :project_type_value

      t.timestamps null: false
    end
    add_foreign_key :basic_projects, :people, column: :primary_agent_id
    add_foreign_key :basic_projects, :people, column: :secondary_agent_id
  end
end
