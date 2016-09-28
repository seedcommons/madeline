# -*- SkipSchemaAnnotations
module Legacy

  class ProjectEvent < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel


    # note, legacy data includes 11 references to a '0' member_id
    def agent_id
      if member_id == 0
        $stderr.puts "ProjectEvent[#{id}] - mapping 0 MemberId ref to null"
        nil
      else
        if Person.where(id: member_id).count > 0
          member_id
        else
          $stderr.puts "ProjectEvent[#{id}] - Person not found for MemberId: #{member_id}, mapping MemberId ref to null"
        end
      end
    end


    def migration_data
      data = {
          id: self.id,
          project_type: project_table.singularize.capitalize,
          project_id: project_id,
          agent_id: agent_id,
          scheduled_start_date: date,
          actual_end_date: completed,
          is_finalized: finalized,
          step_type_value: MIGRATION_TYPE_OPTIONS.value_for(type),
          # type_option_value: ::ProjectStep.step_type_option_set.value_for_migration_id(type)
          scheduled_duration_days: duration,
      }
      data
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:project_id]}"
      ::ProjectStep.create(data)
    end

    def migrate_parent
      puts "setting #{id}: with parent #{milestone_group}"
      step = TimelineEntry.find(id)
      step.parent = TimelineEntry.find(milestone_group)
      step.save
    rescue StandardError => e
      $stderr.puts "ProjectStep[#{id}] error migrating parent: #{e} - skipping"
    end

    def migrate_schedule_parent
      puts "setting #{id}: with schedule parent #{dependent_date}"
      step = TimelineEntry.find(id)
      step.schedule_parent = TimelineEntry.find(dependent_date)
      step.save
    rescue StandardError => e
      $stderr.puts "ProjectStep[#{id}] error migrating schedule parent: #{e} - skipping"
    end


    def self.migrate_all
      puts "project steps: #{Legacy::ProjectEvent.count}"
      # make sure to precalibrate our project steps sequence since we'll be needing to add some default project steps
      # on the fly to handle the orphaned logs
      max = self.connection.execute("select max(id) from ProjectEvents").first.first
      puts "setting projects_step_id_seq to: #{max + 1000}"
      ::ProjectStep.recalibrate_sequence(id: max + 1000)

      # note record 10155 has a malformed date (2013-12-00) which was causing low level barfage
      step_events = self.where("Type = 'Paso' and #{malformed_date_clause('Completed')}")

      step_events.find_each &:migrate
      step_children = step_events.where.not(milestone_group: nil)

      puts "Changing parent steps into ProjectGroups"
      child_ids = step_children.pluck(:milestone_group)
      TimelineEntry.where(id: child_ids).update_all(type: "ProjectGroup")

      step_children.find_each &:migrate_parent
      step_events.where.not(dependent_date: nil).find_each &:migrate_schedule_parent

      # note there will be a few unneeded translation records migrated, but not enough to worry about
      puts "step translations: #{ Legacy::Translation.where('RemoteTable' => 'ProjectEvents').count }"
      Legacy::Translation.where('RemoteTable' => 'ProjectEvents').each &:migrate
      # note, translations table no longer needs recalibrating
    end

    def self.purge_migrated
      # note, not complete, but sufficient for purpose
      puts "::TimelineEntry.delete_all"
      ::TimelineEntry.delete_all
      puts "::TimelineEntry.rebuild!"
      TimelineEntry.rebuild!
    end


    MIGRATION_TYPE_OPTIONS = TransientOptionSet.new(
        [ [:milestone, 'Paso'],
          [:agenda, 'Agenda'], # note, agenda items not currently scoped for migration
        ]
    )


  end

end
