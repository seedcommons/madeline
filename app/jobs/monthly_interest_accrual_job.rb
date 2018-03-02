class MonthlyInterestAccrualJob < ApplicationJob
  def perform
    Accounting::Quickbooks::Updater.new.update(Loan.active)
  end
end
