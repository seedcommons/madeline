class UpdateAllLoansJob < TaskJob
  def perform(job_params)
    task = Task.find(job_params[:task_id])
    errors_by_loan = []
    loans = Loan.all
    updater = Accounting::Quickbooks::Updater.new
    task.update(activity_message_value: "syncing_with_quickbooks")
    updater.qb_sync_for_loan_update
    task.update(activity_message_value: "updating_all_loans")
    loans.each do |loan|
      begin
        updater.update_loan(loan)
      rescue StandardError => error
        errors_by_loan << {loan_id: loan.id, message: error.message}
        next
      end
    end
    Task.find(job_params[:task_id]).update(
      custom_error_data: errors_by_loan,
      activity_message_value: "finished_with_custom_error_data"
    )
  end
end
