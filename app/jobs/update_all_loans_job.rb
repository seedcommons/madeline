class UpdateAllLoansJob < TaskJob
  def perform(job_params)
    task = Task.find(job_params[:task_id])
    errors_by_loan = []
    loans = Loan.all
    updater = Accounting::Quickbooks::Updater.new
    task.set_activity_message("syncing_with_quickbooks")
    updater.qb_sync_for_loan_update
    loans.each_with_index do |loan, index|
      task.set_activity_message("updating_all_loans", {so_far: (index), total: loans.count})
      begin
        updater.update_loan(loan)
      rescue StandardError => error
        errors_by_loan << {loan_id: loan.id, message: error.message}
        next
      end
    end
    task.update(custom_error_data: errors_by_loan)
    task.set_activity_message("finished_with_custom_error_data")
  end
end
