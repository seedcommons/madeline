class MonthlyInterestAccrual < ApplicationJob
  def perform
    Accounting::InterestCalculator.
  end
end
