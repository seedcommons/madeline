# -*- SkipSchemaAnnotations
module Legacy

  class ProjectEvent < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel


    # note, legacy data includes 11 references to a '0' member_id
    def agent_id
      if member_id == 0
        puts "ProjectEvent[#{id}] - mapping 0 MemberId ref to null"
        nil
      else
        member_id
      end
    end


    def migration_data
      data = {
          id: self.id,
          project_type: project_table.singularize.capitalize,
          project_id: project_id,
          agent_id: agent_id,
          scheduled_date: date,
          completed_date: completed,
          is_finalized: finalized,
          type_option_id: ::ProjectStep::MIGRATION_TYPE_OPTIONS.value_for(type),
      }
      data
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:project_id]}"
      ::ProjectStep.create(data)
    end


    def self.migrate_all
      puts "project steps: #{Legacy::ProjectEvent.count}"
      # make sure to precalibrate our project steps sequence since we'll be needing to add some default project steps
      # on the fly to handle the orphaned logs
      max = self.connection.execute("select max(id) from ProjectEvents").first.first
      puts "setting projects_step_id_seq to: #{max+1000}"
      ::ProjectStep.connection.execute("SELECT setval('project_steps_id_seq', #{max+1000})")

      # note record 10155 has a malformed date (2013-12-00) which was causing low level barfage
      self.where("Type = 'Paso' and #{malformed_date_clause('Completed')}").each &:migrate

      # note there will be a few unneeded translation records migrated, but not enough to worry about
      puts "step translations: #{ Legacy::Translation.where('RemoteTable' => 'ProjectEvents').count }"
      Legacy::Translation.where('RemoteTable' => 'ProjectEvents').each &:migrate
      # note, translations table no longer needs recalibrating
    end

    def self.purge_migrated
      # note, not complete, but sufficient for purpose
      puts "::ProjectStep.delete_all"
      ::ProjectStep.delete_all
    end



  end

end
