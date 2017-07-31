class AddNumberToLoanQuestion < ActiveRecord::Migration
  def change
    add_column :loan_questions, :number, :integer, index: true
  end
end
