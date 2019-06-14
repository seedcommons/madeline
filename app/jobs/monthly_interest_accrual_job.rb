class MonthlyInterestAccrualJob < TaskJob
  def perform(_job_params)
    # Updates monthly interest accrual for all loans so that loans whose interest accrual
    # are note updated by user behavior still get updated.
    # Run as a background job once a month.
    # The updater should only be run for active loans in divisions connected to QuickBooks.
    divisions = Division.qb_accessible_divisions
    loans = divisions.map { |i| i.loans.active }.flatten.compact
    Accounting::Quickbooks::Updater.new.update(loans)
  end
end
