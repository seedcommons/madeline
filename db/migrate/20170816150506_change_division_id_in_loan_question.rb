class ChangeDivisionIdInLoanQuestion < ActiveRecord::Migration
  def up
    # Change column from string to integer
    LoanQuestion.all.each { |q| q.update_attribute(:division_id, nil) }
    change_column :loan_questions, :division_id, :integer, using: 'division_id::integer'
    LoanQuestion.all.each { |q| q.update_attribute(:division_id, 99) }

    change_column_null :loan_questions, :division_id, false
  end

  def down
    # Change column from integer to string
    change_column :loan_questions, :division_id, :string
    LoanQuestion.all.each { |q| q.update_attribute(:division_id, 99) }

    change_column_null :loan_questions, :division_id, true
  end
end
