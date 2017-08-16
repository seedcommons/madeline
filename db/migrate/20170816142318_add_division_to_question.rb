class AddDivisionToQuestion < ActiveRecord::Migration
  def change
    add_column :loan_questions, :division_id, :string
  end
end
