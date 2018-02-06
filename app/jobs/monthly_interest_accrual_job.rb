class MonthlyInterestAccrualJob < ApplicationJob
  def perform
    # Accounting::InterestCalculator.recalculate
  end
end
