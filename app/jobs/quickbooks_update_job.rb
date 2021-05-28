class QuickbooksUpdateJob < TaskJob
  def perform(_job_params)
    errors_by_loan = []
    updater = Accounting::QB::Updater.new
    updater.qb_sync_for_loan_update
    task.set_activity_message("syncing_with_quickbooks")
    loans.each_with_index do |loan, index|
      task.set_activity_message("updating_loans", so_far: (index), total: loans.count)
      begin
        updater.update_loan(loan)
      rescue StandardError => e
        # If QB is down, no point in continuing, so re-raise
        raise if e.is_a?(Quickbooks::ServiceUnavailable)

        # If there is an unhandled error updating an individual loan, we don't want the whole process to fail.
        # We let the user know that there was a system error and we've been notified.
        # But we don't expose the original error message to the user since it won't be intelligble
        # and could be a security issue.
        errors_by_loan << {loan_id: loan.id, message: I18n.t("system_error_notified")}

        Accounting::LoanIssue.create!(level: :error, loan: loan, message: :system_error_notified)

        # We want to receive a loud notification about an unhandled error.
        # If we find this is often generating a lot of similar errors
        # then we should really start using Sentry or some other service to group them.
        notify_of_error(e)
      end
    end
    if errors_by_loan.empty?
      task.set_activity_message("completed")
    else
      handle_child_errors(task, errors_by_loan)
    end
  end

  rescue_from(Accounting::QB::NotConnectedError) do |error|
    task.set_activity_message("error_quickbooks_not_connected")
    Accounting::LoanIssue.create!(level: :error, message: :quickbooks_not_connected)
    record_failure_and_raise_error(error)
  end

  rescue_from(Accounting::QB::DataResetRequiredError) do |error|
    task.set_activity_message("error_data_reset_required")
    Accounting::LoanIssue.create!(level: :error, message: :data_reset_required)
    record_failure_and_raise_error(error)
  end

  rescue_from(Accounting::QB::AccountsNotSelectedError) do |error|
    task.set_activity_message("error_quickbooks_accounts_not_selected")
    Accounting::LoanIssue.create!(level: :error, message: :quickbooks_accounts_not_selected)
    record_failure_and_raise_error(error)
  end

  rescue_from(Quickbooks::ServiceUnavailable) do |error|
    task.set_activity_message("error_quickbooks_unavailable")
    Accounting::LoanIssue.create!(level: :error, message: :quickbooks_unavailable)
    record_failure_and_raise_error(error)
  end

  rescue_from(TaskHasChildErrorsError) do |error|
    task.set_activity_message("finished_with_custom_error_data")
    record_failure_and_raise_error(error)
  end

  protected

  def divisions
    @divisions ||= Division.qb_accessible_divisions
  end

  private

  def handle_child_errors(task, errors_by_loan)
    task.update(custom_error_data: errors_by_loan)
    raise TaskHasChildErrorsError.new("Some loans failed to update.")
  end

  def record_failure_and_raise_error(error)
    task.fail!
    notify_of_error(error)

    # Re-raise so the job system sees the error and acts accordingly.
    raise error
  end
end
