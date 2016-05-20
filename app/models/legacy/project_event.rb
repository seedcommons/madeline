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
        if Person.where(id: member_id).count > 0
          member_id
        else
          puts "ProjectEvent[#{id}] - Person not found for MemberId: #{member_id}, mapping MemberId ref to null"
        end
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
          step_type_value: MIGRATION_TYPE_OPTIONS.value_for(type),
          # type_option_value: ::ProjectStep.step_type_option_set.value_for_migration_id(type)
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
      puts "setting projects_step_id_seq to: #{max + 1000}"
      ::ProjectStep.recalibrate_sequence(id: max + 1000)

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


    MIGRATION_TYPE_OPTIONS = TransientOptionSet.new(
        [ [:milestone, 'Paso'],
          [:agenda, 'Agenda'], # note, agenda items not currently scoped for migration
        ]
    )


  end

end
