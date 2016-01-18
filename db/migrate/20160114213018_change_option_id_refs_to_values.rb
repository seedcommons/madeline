class ChangeOptionIdRefsToValues < ActiveRecord::Migration
  def change
    remove_column :loans, :status_option_id, :integer
    remove_column :loans, :project_type_option_id, :integer
    remove_column :loans, :loan_type_option_id, :integer
    remove_column :loans, :public_level_option_id, :integer

    add_column :loans, :status_value, :string, index: true
    add_column :loans, :project_type_value, :string
    add_column :loans, :loan_type_value, :string
    add_column :loans, :public_level_value, :string, index: true

    remove_column :project_steps, :type_option_id, :integer
    add_column :project_steps, :step_type_value, :string

    remove_column :project_logs, :progress_metric_option_id, :integer
    add_column :project_logs, :progress_metric_value, :string

    # note, not sure yet which of these fields will need indexes, should add later once that is more clear

  end
end



