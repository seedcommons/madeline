# -*- SkipSchemaAnnotations
module Legacy

class Member < ActiveRecord::Base
  establish_connection :legacy
  include LegacyModel

  def migration_data
    data = {
        id: self.id,
        division_id: ::Division.root_id,
        primary_organization_id: cooperative_id,
        first_name: first_name,
        last_name: last_name,
        name: "#{first_name} #{last_name}",
        primary_phone: phone,
        street_address: address,
        city: city,
        country_id: Country.id_from_name(self.country),
        tax_no: national_id,
    }
    data
  end

  def migrate
    data = migration_data
    puts "#{data[:id]}: #{data[:name]}"
    ::Person.create(data)
  end


  def self.migrate_all
    puts "members: #{ self.count }"
    self.all.each &:migrate
    ::Person.recalibrate_sequence(gap: 1000)
  end

  def self.purge_migrated
    puts "Person.destroy_all"
    ::Person.destroy_all
  end

end

end
