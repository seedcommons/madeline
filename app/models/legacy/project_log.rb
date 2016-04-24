# -*- SkipSchemaAnnotations
module Legacy

  class ProjectLog < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel


    def project
      project_class.find(self.project_id)
    end


    def migrated_loan
      # beware the legacy db has inconsistent casing of the project table name
      if project_table.downcase == 'loans'
        result = ::Loan.find_safe(project_id)
        unless result
          #JE todo: send warnings also to separate log
          puts "WARNING: ignoring ProjectLog[#{id}] pointing to invalid Loan ID: #{project_id}"
        end
      else
        puts "ignoring non-loan project reference"
        nil
      end
    end


    # note, legacy data includes 44 invalid references to a '0' member_id
    def agent_id
      if member_id == 0
        puts "ProjectLog[#{id}] - mapping 0 MemberId ref to null"
        nil
      else
        if Person.where(id: member_id).count > 0
          member_id
        else
          puts "ProjectEvent[#{id}] - Person not found for MemberId: #{member_id}, mapping MemberId ref to null"
        end
      end
    end

    def migration_data
      # note the legacy db has 814 invalid references to either a 0 or 1 PasoID
      if paso_id && paso_id > 1
        project_step_id = paso_id
        if ::ProjectStep.where(id: project_step_id).count == 0
          #JE todo: send warnings also to separate log
          puts "WARNING: ignoring ProjectLog[#{id}] pointing to invalid PasoID: #{paso_id}"
          return nil
        end
      else
        loan = migrated_loan
        return nil  unless loan  # skip invalid record
        project_step_id = loan.default_step.id
        puts "orphan steplog[#{id}] - using default loan step: #{paso_id}"
      end

      data = {
          id: self.id,
          project_step_id: project_step_id,
          agent_id: agent_id,
          progress_metric_value: ::ProjectLog.progress_metric_option_set.value_for_migration_id(progress_metric),
          date: date,
      }
      data
    end

    def migrate
      data = migration_data
      if data
        puts "#{data[:id]}: step id: #{data[:project_step_id]}"
        ::ProjectLog.create(data)
      end
    end


    def self.migrate_all
      puts "project logs: #{self.where('ProjectTable' => 'loans').count}"
      # note, there is one more record with a wacked out date (2005-01-00)
      self.where("ProjectTable = 'loans' and ProjectId > 0 and #{malformed_date_clause('Date')}").each &:migrate
      ::ProjectLog.recalibrate_sequence(gap: 1000)

      # note, there will be a notable number of unneeded translations from basic project logs, consider pruning somehow
      puts "projectlog translations: #{ Legacy::Translation.where('RemoteTable' => 'ProjectLogs').count }"
      Legacy::Translation.where("RemoteTable = 'ProjectLogs' and RemoteID > 0").each &:migrate
      # note, translations table no longer needs recalibrating
    end

    def self.purge_migrated
      # note, not complete, but sufficient for purpose
      puts "ProjectLog.delete_all"
      ::ProjectLog.delete_all
    end


  end

end
