class AddOriginalDateToProjectSteps < ActiveRecord::Migration
  def change
    add_column :project_steps, :original_date, :date
  end
end
