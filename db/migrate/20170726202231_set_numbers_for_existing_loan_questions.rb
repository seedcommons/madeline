class SetNumbersForExistingLoanQuestions < ActiveRecord::Migration
  def up
    LoanQuestion.all.each { |q| q.send(:set_numbers) }
  end
end
