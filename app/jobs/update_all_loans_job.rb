class UpdateAllLoansJob < TaskJob
  def perform(_job_params)
    task = task_for_job(self)
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
    task.add_errors(errors_by_loan)
  end

  rescue_from(Accounting::Quickbooks::NotConnectedError) do |error|
    task_for_job(self).set_activity_message("error_quickbooks_not_connected")
    record_failure_and_raise_error(error)
  end

  rescue_from(Accounting::Quickbooks::DataResetRequiredError) do |error|
    task_for_job(self).set_activity_message("error_data_reset_required")
    record_failure_and_raise_error(error)
  end

  rescue_from(Accounting::Quickbooks::AccountsNotSelectedError) do |error|
    task_for_job(self).set_activity_message("error_quickbooks_accounts_not_selected")
    record_failure_and_raise_error(error)
  end

  private

  def record_failure_and_raise_error(error)
    task_for_job(self).fail!
    ExceptionNotifier.notify_exception(error, data: {job: to_yaml})
    raise error
  end
end
