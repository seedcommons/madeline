class AddNullConstraintToDataTypes < ActiveRecord::Migration[4.2]
  def change
    change_column_null :loan_questions, :data_type, false
    LoanQuestion.where(data_type: nil).destroy_all
  end
end
