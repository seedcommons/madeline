class UpdateAllLoansJob < TaskJob
  def perform(job_params)
    errors_by_loan = []
    loans = Loan.all[0..30]
    Sidekiq::Logging.logger.info("There are #{loans.count} loans")
    updater = Accounting::Quickbooks::Updater.new
    updater.sync_for_loan_update
    loans.each do |loan|
      begin
        updater.update_loan(loan)
      rescue StandardError => error
        errors_by_loan << {loan_id: loan.id, message: error.message}
        next
      end
    end
    Sidekiq::Logging.logger.info(errors_by_loan.to_s)
    Task.find(job_params[:task_id]).update_attributes(
      custom_error_data: errors_by_loan,
      activity_message_value: "finished_with_custom_error_data"
    )
  end
end
