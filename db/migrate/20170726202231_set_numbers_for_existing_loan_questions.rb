class SetNumbersForExistingLoanQuestions < ActiveRecord::Migration[4.2]
  def up
    LoanQuestion.all.each { |q| q.send(:set_numbers) }
  end
end
