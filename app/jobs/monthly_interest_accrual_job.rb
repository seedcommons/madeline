class MonthlyInterestAccrualJob < ApplicationJob
  def perform
    Accounting::Updater.new(Loan.active)
    # Loan.active.each do |loan|
    #   Accounting::InterestCalculator.new(loan).recalculate if loan.transactions.present?
    # end
  end
end
