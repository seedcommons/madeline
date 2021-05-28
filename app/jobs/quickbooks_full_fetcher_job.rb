# Wraps full quickbooks fetch as task job so that
# its status can be queried and displayed
class QuickbooksFullFetcherJob < TaskJob
  def perform(job_params)
    division = Division.find(job_params[:division_id])
    Accounting::QB::FullFetcher.new(division).fetch_all
    task.set_activity_message("completed")
  end

  rescue_from(Quickbooks::ServiceUnavailable) do |error|
    task.set_activity_message("error_quickbooks_unavailable")
    Accounting::LoanIssue.create!(level: :error, message: :quickbooks_unavailable)
    record_failure_and_raise_error(error)
  end
end
