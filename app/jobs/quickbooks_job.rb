# Parent class for all Quickbooks task jobs
class QuickbooksJob < TaskJob
  rescue_from(Quickbooks::ServiceUnavailable) do |error|
    Accounting::LoanIssue.create!(level: :error, message: :quickbooks_unavailable)
    record_failure_and_raise_error(error, message: "error_quickbooks_unavailable")
  end

  # Override the default TaskJob handling of StandardError to create a LoanIssue
  rescue_from(StandardError) do |error|
    Accounting::LoanIssue.create!(level: :error, message: :system_error_notified)
    record_failure_and_raise_error(error)
  end
end
