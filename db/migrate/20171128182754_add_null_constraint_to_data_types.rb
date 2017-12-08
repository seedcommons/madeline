class AddNullConstraintToDataTypes < ActiveRecord::Migration
  def change
    change_column_null :loan_questions, :data_type, false
    LoanQuestion.where(data_type: nil).destroy_all
  end
end
