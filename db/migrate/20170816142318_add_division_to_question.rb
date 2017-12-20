class AddDivisionToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :loan_questions, :division_id, :integer
  end
end
