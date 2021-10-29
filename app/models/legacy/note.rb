# -*- SkipSchemaAnnotations
module Legacy
  class Note < ApplicationRecord
    establish_connection :legacy
    include LegacyModel

    def migrate
      data = migration_data
      pp(data)

      # Sometimes author is blank, which the DB allow, but validations don't.
      ::Note.new(data).save(validate: false)
    end

    def migration_data
      data = {
        notable_type: "Organization",
        notable_id: noted_id, # Org IDs are same on old and new systems
        author_id: author_id,
        created_at: date,
        text_es: note
      }
      data
    end

    private

    def author_id
      if Migration::NULLIFY_MEMBER_IDS.include?(member_id)
        Migration.log << ["Note", id, "Nullified agent_id b/c member #{member_id} not found"]
        nil
      else
        if (person_id = map_legacy_person_id(member_id))
          person_id
        else
          Migration.unexpected_errors << "Person not found for MemberId: #{member_id} on Note #{id}"
          nil
        end
      end
    end
  end
end
