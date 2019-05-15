class MonthlyInterestAccrualJob < TaskJob
  def perform(job_params)
    # The updater should only be run for active loans in divisions connected to QuickBooks.
    divisions = Division.qb_accessible_divisions
    loans = divisions.map { |i| i.loans.active }.flatten.compact
    Accounting::Quickbooks::Updater.new.update(loans)
  end
end
