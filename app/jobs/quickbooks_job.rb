# Parent class for all Quickbooks task jobs
class QuickbooksJob < TaskJob
  rescue_from(Accounting::QB::NotConnectedError) do |error|
    Accounting::SyncIssue.create!(level: :warning, message: :quickbooks_not_connected)
    record_failure_and_raise_error(error, message: "error_quickbooks_not_connected")
  end

  # We only create a warning because we don't want to hide all loans transaction
  # data just because QB is down for a bit.
  rescue_from(Quickbooks::ServiceUnavailable) do |error|
    Accounting::SyncIssue.create!(level: :warning, message: :quickbooks_unavailable_fetch)
    record_failure_and_raise_error(error, message: "error_quickbooks_unavailable")
  end

  # Override the default TaskJob handling of StandardError to create a SyncIssue
  # We only create a warning because if the exception rises to this level, it must have been
  # during fetch. We don't want to hide all loans transaction data in this case.
  rescue_from(StandardError) do |error|
    Accounting::SyncIssue.create!(level: :warning, message: :system_error_fetch)
    record_failure_and_raise_error(error)
  end
end
