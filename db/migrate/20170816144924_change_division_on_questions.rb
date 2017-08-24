class ChangeDivisionOnQuestions < ActiveRecord::Migration
  def up
    execute("UPDATE loan_questions SET division_id=99")
  end
end
