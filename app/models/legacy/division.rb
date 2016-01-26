# -*- SkipSchemaAnnotations

# note, it's not ideal to muddy our app/models directory with the migration code,
# but the rail class loading behavior seemed happiest with this location.
# can perhaps sort that out later and force to work from a different source directory
module Legacy

  class Division < ActiveRecord::Base
    establish_connection :legacy

    include LegacyModel

    def migration_data
      if id == super_division
        parent_id = ::Division.root_id
      else
        parent_id = super_division
      end
      data = {
          id: id,
          parent_id: parent_id,
          name: name,
          description: description,
          # note, no well defined division currency in current model (aside from the global AR$ default)
          # currency_id:
      }
      data
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:name]}"
      ::Division.create(data)
    end


    def self.migrate_all
      puts {"divisions: #{self.count}"}
      self.all.each &:migrate
      ::Division.recalibrate_sequence(gap: 1)
    end

    def self.purge_migrated
      puts "::Division.where('id <> 99').delete_all"
      ::Division.where.not(id: ::Division.root_id).destroy_all

    end

  end

end
