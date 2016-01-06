class AlterLoans < ActiveRecord::Migration
  def change
    add_column :loans, :name, :string
    remove_column :loans, :status
    add_column :loans, :status_option_id, :integer, index: true
    add_column :loans, :project_type_option_id, :integer
    add_column :loans, :loan_type_option_id, :integer, index: true
    remove_column :loans, :publicity_status
    add_column :loans, :public_level_option_id, :integer, index: true
    add_reference :loans, :organization_snapshot, index: true, foreign_key: false
  end
end
