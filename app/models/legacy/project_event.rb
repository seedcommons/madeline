# -*- SkipSchemaAnnotations
module Legacy

  class ProjectEvent < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel

    # note, legacy data includes 11 references to a '0' member_id
    def agent_id
      if member_id == 0
        # $stderr.puts "ProjectEvent[#{id}] - mapping 0 MemberId ref to null"
        nil
      else
        if Person.where(id: member_id).count > 0
          member_id
        else
          $stderr.puts "ProjectEvent[#{id}] - Person not found for MemberId: #{member_id}, mapping MemberId ref to null"
        end
      end
    end

    def loan
      @loan ||= Loan.where(id: project_id).first
    end

    def loan_id
      if loan.blank?
        $stderr.puts "ProjectEvent[#{id}] - Loan #{project_id} not found"
        nil
      else
        loan.id
      end
    end


    def migration_data
      data = {
          id: self.id,
          project_type: project_table.singularize.capitalize,
          project_id: loan_id,
          agent_id: agent_id,
          is_finalized: (finalized == 1),
          step_type_value: MIGRATION_TYPE_OPTIONS.value_for(type),
          # type_option_value: ::ProjectStep.step_type_option_set.value_for_migration_id(type)
      }
      data
    end

    def migration_step_data
      migration_data.merge(
        scheduled_start_date: date,
        actual_end_date: completed,
        scheduled_duration_days: duration,
      )
    end

    def migrate_step
      data = migration_step_data
      puts "ProjectStep[#{data[:id]}] #{data[:project_id]}"
      step = ::ProjectStep.new(data)

      step.parent = find_or_create_parent_group

      step.save!
      step
    rescue StandardError => e
      $stderr.puts "#{step.class.name}[#{id}] error migrating step, could not find loan #{data[:project_id]}: #{e} - skipping"
    end

    def find_or_create_parent_group
      return unless loan
      ProjectGroup.find_or_create_by(project_type: "Loan", project_id: loan.id)
    end

    def children
      Legacy::ProjectEvent.migratable.where(milestone_group: id)
    end

    def migrate_group
      data = migration_data
      puts "ProjectGroup[#{data[:id]}] #{data[:project_id]}"
      ::ProjectGroup.create!(data)
      children.each(&:migrate)
    rescue StandardError => e
      $stderr.puts "#{step.class.name}[#{id}] error migrating group: #{e} - skipping"
    end

    # def migrate_parent
    #   puts "setting #{id}: with parent #{milestone_group}"
    #   step = TimelineEntry.find(id)
    #   step.parent = TimelineEntry.find(milestone_group)
    #   step.save!
    # rescue StandardError => e
    #   $stderr.puts "#{step.class.name}[#{id}] error migrating parent: #{e} - skipping"
    # end

    def migrate_schedule_parent
      puts "setting #{id}: with schedule parent #{dependent_date}"
      step = TimelineEntry.find(id)
      schedule_parent = TimelineEntry.find(dependent_date)
      if schedule_parent.step?
        step.schedule_parent = schedule_parent
      else
        puts "schedule parent is a group, copying date instead"
        step.scheduled_start_date = find_dependent_date(dependent_date)
      end
      step.save!
    rescue StandardError => e
      $stderr.puts "#{step.class.name}[#{id}] error migrating schedule parent: #{e} - skipping"
    end

    def copy_date_from_group_to_step
      child_events = Legacy::ProjectEvent.where(dependent_date: id)
      return unless child_events.count > 0
      found_date = date || find_dependent_date(dependent_date)
      if found_date
        puts "ProjectGroup[#{id}]: Copying date to children (#{child_events.pluck(:id).join(', ')})"
        child_events.find_each{ |event| set_date_on_step(event.id, found_date) }
      else
        $stderr.puts "ProjectGroup[#{id}]: Missing Date, DependentDate[#{dependent_date}]"
      end
    rescue StandardError => e
      $stderr.puts "#{step.class.name}[#{id}] error copying date from group to step: #{e} - skipping"
    end

    def set_date_on_step(step_id, date)
      step = TimelineEntry.where(id: step_id).first
      if step
        if step.step? && step.scheduled_start_date.blank?
          puts "#{step.class.name}[#{step_id}] Setting #{step_id} to #{date}"
          step.scheduled_start_date = date
          step.save!
        else
          puts "#{step.class.name}[#{step_id}] skipping"
        end
      else
        $stderr.puts "Step #{step_id} not found"
      end
    end

    def find_dependent_date(dependent_date_id)
      event = Legacy::ProjectEvent.find(dependent_date_id)
      return event.date if event.date
      find_dependent_date(event.dependent_date)
    rescue StandardError => e
      $stderr.puts e
    end

    def migrate
      if self.class.group_ids.include? id
        migrate_group
      else
        migrate_step
      end
    end

    def self.migratable
      # note record 10155 has a malformed date (2013-12-00) which was causing low level barfage
      # Don't migrate Finalized = -1 per Brendan 11/9/16
      where("Type = 'Paso' and Finalized > -1 and #{malformed_date_clause('Completed')}").where(project_table: 'Loans')
    end

    def self.step_children
      migratable.where.not(milestone_group: nil)
    end

    def self.group_ids
      @group_ids ||= step_children.pluck(:milestone_group).uniq
    end

    def self.roots
      migratable.where(milestone_group: nil)
    end

    def self.migrate_all
      puts "project steps: #{Legacy::ProjectEvent.count}"
      # make sure to precalibrate our project steps sequence since we'll be needing to add some default project steps
      # on the fly to handle the orphaned logs
      max = self.connection.execute("select max(id) from ProjectEvents").first.first
      puts "setting projects_step_id_seq to: #{max + 1000}"
      ::ProjectStep.recalibrate_sequence(id: max + 1000)

      ProjectGroup.skip_callback(:create, :before, :ensure_single_root)

      roots.find_each(&:migrate)

      # step_children.find_each &:migrate_parent

      migratable.where("ProjectEvents.DependentDate is not null OR ProjectEvents.date is not null").find_each do |event|
        if group_ids.include? event.id
          event.copy_date_from_group_to_step
        else
          event.migrate_schedule_parent if event.dependent_date
        end
      end

      loan_ids_with_multiple_roots = ProjectGroup.where(parent_id: nil).select(:project_id, :project_type).group(:project_id, :project_type).having("count(*) > 1").pluck(:project_id)
      loan_ids_with_multiple_roots.each do |loan_id|
        puts "Creating new root ProjectGroup for Loan #{loan_id}"
        root = ProjectGroup.create(project_type: "Loan", project_id: loan_id)
        TimelineEntry.where(project_type: "Loan", project_id: loan_id, parent_id: nil).each do |step|
          step.parent = root
          step.save
        end
      end

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
