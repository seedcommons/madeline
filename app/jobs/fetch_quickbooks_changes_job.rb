class FetchQuickbooksChangesJob < TaskJob
  def perform(_job_params)
    task = task_for_job(self)
    errors_by_loan = []
    divisions = Division.qb_accessible_divisions
    updater = Accounting::QB::Updater.new
    updater.qb_sync_for_loan_update

    loans = divisions.map { |i| i.loans.changed_since(updater.qb_connection.last_updated_at).active }.flatten.compact
    task.set_activity_message("syncing_with_quickbooks")
    loans.each_with_index do |loan, index|
      task.set_activity_message("updating_loans", so_far: (index), total: loans.count)
      begin
        updater.update_loan(loan)
      rescue StandardError => error
        errors_by_loan << {loan_id: loan.id, message: error.message}
        next
      end
    end
    if errors_by_loan.empty?
      task_for_job(self).set_activity_message("completed")
    else
      handle_child_errors(task, errors_by_loan)
    end
  end

  rescue_from(Accounting::QB::NotConnectedError) do |error|
    task_for_job(self).set_activity_message("error_quickbooks_not_connected")
    record_failure_and_raise_error(error)
  end

  rescue_from(Accounting::QB::DataResetRequiredError) do |error|
    task_for_job(self).set_activity_message("error_data_reset_required")
    record_failure_and_raise_error(error)
  end

  rescue_from(Accounting::QB::AccountsNotSelectedError) do |error|
    task_for_job(self).set_activity_message("error_quickbooks_accounts_not_selected")
    record_failure_and_raise_error(error)
  end

  rescue_from(TaskHasChildErrorsError) do |error|
    task_for_job(self).set_activity_message("finished_with_custom_error_data")
    record_failure_and_raise_error(error)
  end

  private

  def handle_child_errors(task, errors_by_loan)
    unless errors_by_loan.empty?
      task.update(custom_error_data: errors_by_loan)
      raise TaskHasChildErrorsError.new("Some loans failed to update.")
    end
  end

  def record_failure_and_raise_error(error)
    task_for_job(self).fail!
    ExceptionNotifier.notify_exception(error, data: {job: to_yaml})
    raise error
  end
end
