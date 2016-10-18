# -*- SkipSchemaAnnotations

# note, it's not ideal to muddy our app/models directory with the migration code,
# but the rail class loading behavior seemed happiest with this location.
# can perhaps sort that out later and force to work from a different source directory
module Legacy

  class Division < ActiveRecord::Base
    establish_connection :legacy

    include LegacyModel

    def ensure_country
      # In legacy DB, `country` is a string field containing a country name
      # Sets country to US when not found
      @country ||= Country.find_by(name: country) || Country.find_by(name: 'United States')
    end

    def migration_data
      if id == super_division
        parent_id = ::Division.root_id
      elsif id == 14 # WORCs division workaround
        parent_id = 11 # La Base US
      else
        parent_id = super_division
      end
      data = {
          id: id,
          parent_id: parent_id,
          name: name,
          description: description,
          currency_id: ensure_country.default_currency.id,
      }
      data
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:name]}"
      division = ::Division.find_or_create_by(id: data[:id])
      division.assign_attributes(data)
      division.save(validate: false)

      # todo: confirm how we should assigned default locales to migrated divisions

    end


    def self.migrate_all
      puts {"divisions: #{self.count}"}
      # self.all.each &:migrate

      # Only migrate divisions with loans (for now)
      self.where(id: [2, 4, 7, 11, 13, 14]).each &:migrate
      ::Division.recalibrate_sequence(gap: 1)
    end

    def self.purge_migrated
      while ::Division.count > 1
        puts "::Division.leaves.destroy_all"
        ::Division.leaves.destroy_all
      end
    end

  end

end
