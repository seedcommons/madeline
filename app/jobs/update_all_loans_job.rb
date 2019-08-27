class UpdateAllLoansJob < TaskJob
  def perform(job_params)
    Sidekiq::Logging.logger.info("Hello from perform UpdateAllLoansJob")
    error_messages = []
    loans = Loan.all
    Sidekiq::Logging.logger.info("There are #{loans.count} loans")
    updater = Accounting::Quickbooks::Updater.new
    updater.sync_for_loan_update
    loans[0..20].each do |loan|
      begin
        updater.update_loan(loan)
      rescue StandardError => error
        error_messages << {loan_id: loan.id, message: error.message}
        next
      end
    end
    error_message_string = error_messages.each { |e| "#{e[:loan_id]}: #{e[:message]}" }.join('\n\n')
    Sidekiq::Logging.logger.info(error_message_string)
    Task.find(job_params[:task_id]).update_attribute(:activity_message_value, error_message_string)
  end
end
