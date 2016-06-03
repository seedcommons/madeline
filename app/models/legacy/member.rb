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
        first_name: first_name.try(:strip),
        last_name: last_name.try(:strip),
        name: "#{first_name} #{last_name}",
        primary_phone: phone,
        street_address: address.try(:strip),
        city: city.try(:strip),
        country_id: Country.id_from_name(self.country.try(:strip)),
        tax_no: national_id,
    }
    if access_status > 0 && password.present? && username.present?
      email = "#{username.downcase}@theworkingworld.org"
      if Person.where(email: email).exists?
        puts "skipping system access status for Person #{data[:id]} with non-unique email: #{email}"
      else
        data[:has_system_access] = true
        data[:email] = email
        adjusted_password = password.ljust(8, '0')
        data[:password] = data[:password_confirmation] = adjusted_password
        data[:owning_division_role] = username == 'brendan' ? :admin : :member
      end
    end
    data
  end

  def migrate
    data = migration_data
    puts "#{data[:id]}: #{data[:name]}"
    ::Person.create!(data)
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
