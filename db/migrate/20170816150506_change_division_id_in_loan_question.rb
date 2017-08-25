class ChangeDivisionIdInLoanQuestion < ActiveRecord::Migration
  def change
    change_column_null :loan_questions, :division_id, false
  end
end
