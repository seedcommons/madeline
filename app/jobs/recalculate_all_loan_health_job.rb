class RecalculateAllLoanHealthJob < ApplicationJob
  def perform
    # Create a job for each loan recalculation.
    # The granularity makes it easier to see what loans have problems when they happen.
    Loan.pluck(:id).each do |loan_id|
      RecalculateLoanHealthJob.perform_later(loan_id: loan_id)
    end
  end
end
