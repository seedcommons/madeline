# Wraps full quickbooks fetch as task job so that
# its status can be queried and displayed
class FullFetcherJob < TaskJob
  def perform(job_params)
    division = Division.find(job_params[:division_id])
    Accounting::Quickbooks::FullFetcher.new(division).fetch_all
  end
end
