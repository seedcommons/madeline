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

  desc "A one time task to clean up duplicate and numeric value loan type values in prod data"
  task fix_loan_type_values: :environment do
    return unless OptionSet.exists?(model_type: "Loan", model_attribute: "loan_type")
    # fix duplicates
    duplicate_loan_type_value_pairs = [
      {new: "liquidity_loc", old: "28"},
      {new: "evolving", old: "31"},
      {new: "single_liquidity_loc", old: "32"},
      {new: "wc_investment", old: "33"},
      {new: "sa_investment", old: "34"},
      {new: "community_solar", old: "51"},
      {new: "conversion_phased", old: "54"},
    ]
    loan_type_option_set_id = OptionSet.find_by(model_type: "Loan", model_attribute: "loan_type").id
    duplicate_loan_type_value_pairs.each do |value_pair|
      old = value_pair[:old]
      new = value_pair[:new]
      if Option.exists?(option_set_id: loan_type_option_set_id, value: old)
        old_option = Option.find_by(option_set_id: loan_type_option_set_id, value: old)
        new_option = Option.find_by(option_set_id: loan_type_option_set_id, value: new)

        # update loans table
        Loan.where(loan_type_value: old).update_all(loan_type_value: new)

        # update loan question requirements table
        LoanQuestionRequirement.where(option_id: old_option.id).update_all(option_id: new_option.id)

        # translations table not updated because translation for new option will work after this change
        # as of 2022-01, options have dependent destroy relationship with translations thru the  :translatable concern

        old_option.destroy
      end
    end
    # fix other numeric values
    loan_type_value_pairs = [
      {new: "line_of_credit", old: "29"},
      {new: "expansion", old: "30"},
      {new: "pre_startup_incubation", old: "35"},
      {new: "conversion", old: "36"},
      {new: "startup", old: "37"},
      {new: "intake", old: "46"},
      {new: "conversion_intake", old: "47"},
      {new: "member_share_financing", old: "53"},
      {new: "covid_response_planning", old: "56"},
      {new: "real_estate", old: "57"},
      {new: "bridge", old: "58"},
      {new: "exploratory", old: "59"}
    ]
    loan_type_option_set_id = OptionSet.find_by(model_type: "Loan", model_attribute: "loan_type").id
    loan_type_value_pairs.each do |value_pair|
      old = value_pair[:old]
      new = value_pair[:new]
      if Option.exists?(option_set_id: loan_type_option_set_id, value: old)
        old_option = Option.find_by(option_set_id: loan_type_option_set_id, value: old)
        old_option.update(value: new)

        # update loans table
        Loan.where(loan_type_value: old).update_all(loan_type_value: new)

        # we don't update loan question requirements table because it uses option_ids
        # above we are only changing the value, not the id, of the option
        # translations table not updated because translation table also relies on translatable_id
        # above we are only changing the value, not the id, of the option
      end
    end
  end
end
