class UpdateAllLoansJob < TaskJob
  def perform(job_params)
    Sidekiq::Logging.logger.info("Hello from perform UpdateAllLoansJob")
    error_messages = []
    loans = Loan.all
    Sidekiq::Logging.logger.info("There are #{loans.count} loans")
    updater = Accounting::Quickbooks::Updater.new
    updater.sync_for_loan_update
    loans.each do |loan|
      begin
        updater.update_loan(loan)
      rescue StandardError => error
        error_messages << {loan_id: loan.id, message: error.message}
        next
      end
    end
    Sidekiq::Logging.logger.info(error_messages.to_s)
    Task.find(job_params[:task_id]).update_attributes(
      custom_data: {errors: error_messages},
      activity_message_value: "error_with_custom_data_html"
    )
  end
end
