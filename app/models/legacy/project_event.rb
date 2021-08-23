# -*- SkipSchemaAnnotations
module Legacy
  # The Argentina data did not use groups or dependent dates.
  # So much of the earlier machinery for handling those complexities was deleted.
  class ProjectEvent < ApplicationRecord
    establish_connection :legacy
    include LegacyModel

    NULLIFY_MEMBER_IDS = [0]

    def self.migratable
      where("ProjectTable NOT IN ('BasicProjects', 'ProjectTemplates')")
    end

    # note, legacy data includes 11 references to a '0' member_id, and a bunch to 247 which doesn't exist
    def agent_id
      if NULLIFY_MEMBER_IDS.include?(member_id)
        Migration.log << ["ProjectEvent", id, "Nullified agent_id b/c member #{member_id} not found"]
        nil
      else
        if (person_id = map_legacy_person_id(member_id))
          person_id
        else
          Migration.unexpected_errors << "Person not found for MemberId: #{member_id} on Step #{id}"
          nil
        end
      end
    end

    def loan_id
      if ::Loan.where(id: project_id).exists?
        project_id
      else
        Migration.unexpected_errors << "Loan #{project_id} not found on Step #{id}"
        nil
      end
    end

    # The Argentina data did not use groups or dependent dates.
    def migration_data
      data = {
        legacy_id: id,
        project_id: loan_id,
        agent_id: agent_id,
        is_finalized: (finalized == 1),
        step_type_value: MIGRATION_TYPE_OPTIONS.value_for(type),
        summary: summary,
        scheduled_start_date: date,
        actual_end_date: completed,
        scheduled_duration_days: duration == 0 ? 1 : duration,
        parent: find_or_create_parent_group
      }

      copy_translations(data, from: :summary, to: :summary)
      copy_translations(data, from: :details, to: :details)

      data
    end

    def migrate
      if project_table.downcase != 'loans'
        Migration.log << ["ProjectEvent", id, "Not migrating b/c ProjectTable = #{project_table}"]
        return
      end
      if finalized <= -1
        Migration.log << ["ProjectEvent", id, "Not migrating b/c Finalized = #{finalized}"]
        return
      end
      if type != "Paso"
        Migration.log << ["ProjectEvent", id, "Not migrating b/c Type = '#{type}'"]
        return
      end
      data = migration_data
      pp data
      step = ::ProjectStep.create!(data)
    end

    def find_or_create_parent_group
      return nil if loan_id.nil?
      ProjectGroup.find_or_create_by!(project_id: project_id)
    end

    MIGRATION_TYPE_OPTIONS = TransientOptionSet.new(
        [ [:checkin, 'Paso'],
          [:agenda, 'Agenda'], # note, agenda items not currently scoped for migration
        ]
    )
  end
end
