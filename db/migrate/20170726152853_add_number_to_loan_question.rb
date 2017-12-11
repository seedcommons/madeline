class AddNumberToLoanQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :loan_questions, :number, :integer, index: true
  end
end
