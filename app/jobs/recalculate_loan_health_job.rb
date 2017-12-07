class RecalculateLoanHealthJob < ApplicationJob
  def perform(loan_id:)
    check = LoanHealthCheck.where(loan_id: loan_id).first

    if check.nil?
      return unless Loan.where(id: loan_id).exists?
      check = LoanHealthCheck.create!(loan_id: loan_id)
    end

    check.recalculate
  end
end
