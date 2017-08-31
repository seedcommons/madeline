class RecalculateLoanHealthJob < ActiveJob::Base
  queue_as :default

  def perform(loan_id:)
    check = LoanHealthCheck.where(loan_id: loan_id).first

    unless check
      Rails.logger.debug "Creating health check for loan #{loan_id}"
      check = LoanHealthCheck.create!(loan_id: loan_id)
    end

    check.recalculate
  end
end
