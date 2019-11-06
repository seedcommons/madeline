namespace :one_time_changes do
  desc "A one time task responding to Nov 2019 request to update loan date fields."
  task adjust_loan_dates: :environment do
    Loan.all.each do |l|
      if l.actual_end_date.nil? && l.projected_end_date && l.projected_end_date < Time.zone.today
        new_actual = l.projected_end_date
        new_projected = nil
        Rails.logger.info("AdjustLoanDates: Update loan #{l.id} to have actual end date #{new_actual}, projected end date: #{new_projected}.")
        l.update(actual_end_date: new_actual, projected_end_date: new_projected)
      end
    end
  end
end
