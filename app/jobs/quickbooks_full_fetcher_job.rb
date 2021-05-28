# Wraps full quickbooks fetch as task job so that
# its status can be queried and displayed
class QuickbooksFullFetcherJob < QuickbooksJob
  def perform(job_params)
    division = Division.find(job_params[:division_id])
    Accounting::QB::FullFetcher.new(division).fetch_all
    task.set_activity_message("completed")
  end
end
