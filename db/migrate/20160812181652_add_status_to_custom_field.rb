class AddStatusToCustomField < ActiveRecord::Migration
  def change
    add_column :loan_questions, :status, :string, default: 'active', null: false
  end
end
