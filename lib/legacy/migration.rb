module Legacy

  class Migration

    def self.migrate_all
      Legacy::StaticData.populate
      Legacy::Division.migrate_all
      Legacy::Cooperative.migrate_all
      Legacy::Member.migrate_all
      Legacy::Loan.migrate_all
      Legacy::ProjectEvent.migrate_all
      Legacy::ProjectLog.migrate_all
      Legacy::Note.migrate_all
      Legacy::LoanQuestion.migrate_all
      # save EmbeddableMedia first as those records will now be updated as the LoanResponses are saved
      Legacy::LoanResponsesIFrame.migrate_all
      Legacy::LoanResponseSet.migrate_all
    end

    # the core data which can be quickly migrated
    def self.migrate_core
      Legacy::StaticData.populate
      Legacy::Division.migrate_all
      Legacy::Cooperative.migrate_all
      Legacy::Member.migrate_all
      Legacy::Loan.migrate_all
    end

    def self.migrate_media
      Legacy::Media.migrate_all
    end

    def self.migrate_secondary
      Legacy::ProjectEvent.migrate_all
      Legacy::ProjectLog.migrate_all
      Legacy::Note.migrate_all
      Legacy::LoanQuestion.migrate_all
      # Note, LoanResponseSet logic now pulls in LoanResponsesIFrame data
      Legacy::LoanResponseSet.migrate_all
    end

    def self.purge_migrated
      Legacy::LoanQuestion.purge_migrated
      Legacy::Note.purge_migrated
      Legacy::ProjectLog.purge_migrated
      Legacy::ProjectEvent.purge_migrated
      Legacy::Loan.purge_migrated
      Legacy::Member.purge_migrated
      Legacy::Cooperative.purge_migrated
      Legacy::Division.purge_migrated
    end

    # def malformed_date_clause(field)
    #   " not (#{field} is not null and dayofmonth(#{field}) = 0 and month(#{field}) > 0)"
    # end

  end

end
