class QuickbooksUpdateJob < QuickbooksJob
  attr_accessor :updater

  def perform(_job_params)
    # Delete only global issues now before fetch phase but keep loan-specific
    # issues so that if fetch we still hide those loans' txn data appropriately.
    Accounting::SyncIssue.global.delete_all
    self.updater = Accounting::QB::Updater.new
    started_update_at = Time.current
    updater.qb_sync_for_loan_update
    task.set_activity_message("syncing_with_quickbooks")
    loans.each_with_index do |loan, index|
      task.set_activity_message("updating_loans", so_far: (index), total: loans.count)
      Accounting::QB::ErrorHandler.new(loan:loan, in_background_job: true).handle_qb_errors { updater.update_loan(loan) }
    end

    updater.qb_connection.update_last_updated_at(started_update_at)

    # Even if there have been per-loan errors, we still consider the task completed.
    # If there were per-loan errors that support team needs to be notified of, those notices get sent when
    # the errors are handled.
    task.set_activity_message("completed")
  end

  rescue_from(Accounting::QB::DataResetRequiredError) do |error|
    Accounting::SyncIssue.create!(level: :warning, message: :data_reset_required)
    record_failure_and_raise_error(error, message: "error_data_reset_required")
  end

  rescue_from(Accounting::QB::AccountsNotSelectedError) do |error|
    Accounting::SyncIssue.create!(level: :warning, message: :quickbooks_accounts_not_selected)
    record_failure_and_raise_error(error, message: "error_quickbooks_accounts_not_selected")
  end

  protected

  def divisions
    @divisions ||= Division.qb_accessible_divisions
  end
end
