class MonthlyInterestAccrualJob < ApplicationJob
  def perform
    Loan.active.each do |loan|
      Accounting::InterestCalculator.new(loan).recalculate
    end
  end
end
