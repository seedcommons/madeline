class ChangeDivisionOnQuestions < ActiveRecord::Migration
  def up
    LoanQuestion.all.each { |q| q.update_attribute(:division_id, 99) }
  end

  def down
    LoanQuestion.all.each { |q| q.update_attribute(:division_id, nil) }
  end
end
