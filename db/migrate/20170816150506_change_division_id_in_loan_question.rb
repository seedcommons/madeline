class ChangeDivisionIdInLoanQuestion < ActiveRecord::Migration[4.2]
  def change
    change_column_null :loan_questions, :division_id, false
  end
end
