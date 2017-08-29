class SetNumbersForExistingLoanQuestions < ActiveRecord::Migration
  def up
    Question.all.each { |q| q.send(:set_numbers) }
  end
end
