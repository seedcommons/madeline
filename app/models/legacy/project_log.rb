# -*- SkipSchemaAnnotations
module Legacy

  class ProjectLog < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel

# ##~~~~~  remove_method :progress, :progress_metric
#
#   belongs_to :member, :foreign_key => 'MemberID'
#   belongs_to :paso, :foreign_key => 'PasoID'
#   belongs_to :progress_metric, :foreign_key => 'ProgressMetric'
#   # attr_accessible :AdditionalNotes, :Date, :ProjectID, :ProjectTable
#
#   def project_class
#     # return Legacy::Loan  if project_table == 'loans'
#     # return Legacy::BasicProject  if project_table == 'BasicProjects'
#     case project_table.downcase
#       when 'loans'
#         Legacy::Loan
#       when 'basicprojects'
#         Legacy::BasicProject
#       else
#         raise "unexpected project_table: #{project_table}"
#     end
#   end

    def project
      project_class.find(self.project_id)
    end


    def migrated_loan
      # beware the legacy db has inconsistent casing of the project table name
      if project_table.downcase == 'loans'
        ::Loan.find(project_id)
      else
        puts "ignoring non-loan project reference"
        nil
      end
    end


# def explanation
#   self.translation('Explanation')
# end
# def detailed_explanation
#   self.translation('DetailedExplanation')
# end
#
# def progress(continuous=false)
#   language = (I18n.locale == :es ? 'Spanish' : 'English')
#   field_name = (continuous ? 'Continuous' : 'WithEvents')
#   self.progress_metric.send(language + 'Display' + field_name).capitalize # e.g. EnglishDisplayWithEvents
# end
# def progress_continuous
#   self.progress(true)
# end
#
# def media(limit=100, images_only=false)
#   get_media('ProjectLogs', self.id, limit, images_only)
# end

    def migration_data
      if paso_id
        project_step_id = paso_id
      else
        loan = migrated_loan
        project_step_id = loan.default_step.id
        puts "orphan steplog[#{id}] - using default loan step: #{paso_id}"
      end

      data = {
          id: self.id,
          project_step_id: project_step_id,
          agent_id: member_id,
          # progress_metric_option_id: ::ProjectLog::MIGRATION_PROGRESS_METRIC_OPTION_ID.value_for(progress_metric)
          # this will use the raw int values -3 -> 3, should perhaps renormalize to positive integers
          progress_metric_option_id: progress_metric,
          date: date,
      }
      data
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:project_step_id]}"
      ::ProjectLog.create(data)
    end


    def self.migrate_all
      puts "project logs: #{self.where('ProjectTable' => 'loans').count}"
      # note, there is one more record with a wacked out date (2005-01-00)
      self.where("ProjectTable = 'loans' and ProjectId > 0 and #{malformed_date_clause('Date')}").each &:migrate
      ::ProjectLog.connection.execute("SELECT setval('project_logs_id_seq', (SELECT MAX(id) FROM project_logs)+1000)")

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
