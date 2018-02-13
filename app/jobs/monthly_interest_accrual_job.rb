class MonthlyInterestAccrualJob < ApplicationJob
  def perform
    Accounting::Updater.new.update(Loan.active)
  end
end
