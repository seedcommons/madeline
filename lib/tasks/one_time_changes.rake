namespace :one_time_changes do
  desc "A one time task responding to Nov 2019 request to update loan date fields."
  task adjust_loan_dates: :environment do
    Loan.find_each do |l|
      if l.actual_end_date.nil? && l.projected_end_date && l.projected_end_date < Time.zone.today
        new_actual = l.projected_end_date
        new_projected = nil
        Rails.logger.info("AdjustLoanDates: Update loan #{l.id} to have actual end date #{new_actual}, projected end date: #{new_projected}.")
        l.update(actual_end_date: new_actual, projected_end_date: new_projected)
      end
    end
  end

  desc "Resave all organizations to run any new callbacks and
  check against any new validations. Created to be run manually
  on each server after deploying 10407, in which whitespace is stripped on save"
  task resave_all_organizations: :environment do
    org_ids_with_errors = {}
    Organization.find_each do |o|
      begin
       o.save!
     rescue
       org_ids_with_errors[o.id] = o.errors.messages
     end
    end
    pp org_ids_with_errors
  end
end
