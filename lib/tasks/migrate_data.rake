namespace :tww do

  desc "migrate TWW data from legacy mysql to new postgres db"
  task :migrate_legacy => :environment do

    # Legacy::Division.migrate_all
    # Legacy::Cooperative.migrate_all
    # Legacy::Member.migrate_all
    # Legacy::Loan.migrate_all
    # Legacy::ProjectEvent.migrate_all
    # Legacy::ProjectLog.migrate_all
    # Legacy::Note.migrate_all
    Legacy::LoanQuestion.migrate_all

  end


  # note, this task isn't really needed.  generally better to just drop the db,
  # but has been useful when retesting partial migrations during development
  desc "purge target (postgres) data"
  task :purge_migrated => :environment do
    Legacy::LoanQuestion.purge_migrated
    # Legacy::Note.purge_migrated
    # Legacy::ProjectLog.purge_migrated
    # Legacy::ProjectEvent.purge_migrated
    # Legacy::Loan.purge_migrated
    # Legacy::Member.purge_migrated
    # Legacy::Cooperative.purge_migrated
    # Legacy::Division.purge_migrated
  end

  # def malformed_date_clause(field)
  #   " not (#{field} is not null and dayofmonth(#{field}) = 0 and month(#{field}) > 0)"
  # end


end
