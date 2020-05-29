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

  desc "Resave all records (except excluded tables including Proejcts) to run any new callbacks and
  check against any new validations. Created to be run manually
  on each server after deploying 10407, in which whitespace is stripped on save"
  task resave_all_records: :environment do
    # Projects excluded because 'updated_at' on loans used in accounting logic.
    # ProgressMetric and Repayment models do not have tables
    # Media does not have user-facing fields and takes a long time to resave
    classes_to_skip = %w(Project ProgressMetric Media Repayment)
    Dir[Rails.root + 'app/models/*.rb'].each do |path|
      require path
    end
    Dir[Rails.root + 'app/models/accounting/*.rb'].each do |path|
      require path
    end
    klasses = ApplicationRecord.subclasses
    puts "Resaving records for #{klasses.count} classes . . .\n\n"
    klasses.each do |klass|
      name = klass.name
      if classes_to_skip.include?(name) || name.match?("Legacy")
        puts "SKIPPING class #{name}\n\n"
      else
        puts "BEGIN updating records of class #{name}. . . "
        records_with_errors = {}
        klass.find_each do |record|
          begin
            record.save!
          rescue
            records_with_errors [record.id] = record.errors.messages
          end
        end
        if records_with_errors.empty?
          puts "No errors raised while resaving records of class #{name}"
        else
          pp records_with_errors
        end
        puts "END updating records of class #{name}.\n\n"
      end
    end
  end
end
