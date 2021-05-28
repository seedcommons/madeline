class QuickbooksUpdateJob < QuickbooksJob
  def perform(_job_params)
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
        Accounting::LoanIssue.create!(level: :error, loan: loan, message: :system_error_notified)

        # We want to receive a loud notification about an unhandled error.
        # If we find this is often generating a lot of similar errors
        # then we should really start using Sentry or some other service to group them.
        notify_of_error(e)
      end
    end

    # Even if there have been per-loan errors, we still consider the task completed.
    # If there were per-loan errors that support team needs to be notified of, those notices get sent when
    # the errors are handled.
    task.set_activity_message("completed")
  end

  rescue_from(Accounting::QB::NotConnectedError) do |error|
    Accounting::LoanIssue.create!(level: :error, message: :quickbooks_not_connected)
    record_failure_and_raise_error(error, message: "error_quickbooks_not_connected")
  end

  rescue_from(Accounting::QB::DataResetRequiredError) do |error|
    Accounting::LoanIssue.create!(level: :error, message: :data_reset_required)
    record_failure_and_raise_error(error, message: "error_data_reset_required")
  end

  rescue_from(Accounting::QB::AccountsNotSelectedError) do |error|
    Accounting::LoanIssue.create!(level: :error, message: :quickbooks_accounts_not_selected)
    record_failure_and_raise_error(error, message: "error_quickbooks_accounts_not_selected")
  end

  protected

  def divisions
    @divisions ||= Division.qb_accessible_divisions
  end
end
