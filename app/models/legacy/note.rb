# -*- SkipSchemaAnnotations
module Legacy

  class Note < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel


    def migration_data
      data = {
          id: self.id,
          notable_type: notable_type,
          notable_id: noted_id,
          person_id: member_id,
          created_at: date,
      }
      data
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:notable_id]}"
      obj = ::Note.create(data)
      # need to save this as a second pass because it's translatable
      obj.update({text: note})
    end


    def notable_type
      return 'Organization'  if self.noted_table == 'Cooperatives'
      raise "unexpected NotedTable value: #{noted_table}"
    end


    def self.migrate_all
      puts "notes logs: #{self.where('NotedTable' => 'Cooperatives').count}"
      self.where('NotedTable' => 'Cooperatives').each &:migrate
      ::Note.connection.execute("SELECT setval('notes_id_seq', (SELECT MAX(id) FROM notes)+1000)")
    end

    def self.purge_migrated
      # note, not complete, but sufficient for purpose
      puts "::Note.delete_all"
      ::Note.delete_all
    end


  end

end
