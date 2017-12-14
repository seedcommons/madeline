class ChangeDivisionOnQuestions < ActiveRecord::Migration[4.2]
  def up
    execute("UPDATE loan_questions SET division_id=99")
  end
end
