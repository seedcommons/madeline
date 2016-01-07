module Legacy

class Cooperative < ActiveRecord::Base
  establish_connection :legacy
  include LegacyModel


  # def verbose_name
  #   @verbose_name ||= (self.name =~ /#{I18n.t :cooperative}/i) ? self.name : I18n.t(:cooperative_name, name: self.name)
  # end

  def migration_data
    data = {
        id: self.id,
        division_id: ::Division.root_id,
        name: name,
        legal_name: nombre_legal_completo,
        primary_phone: telephone,
        email: email,
        street_address: address,
        city: city,
        neighborhood: borough,
        state: state,
        country_id: Country.id_from_name(self.country),
        tax_no: tax_id,
        #todo: figure out why this bombs, perhaps because source column is already lower case
        #website: web,
        alias: self.alias,
        ##todo: is_recovered: recuperada, - once custom fields are implemented
        sector: sector,
        industry: industry,
        referral_source: source,
    }
    data
  end

  def migrate
    data = migration_data
    puts "#{data[:id]}: #{data[:name]}"
    ::Organization.create(data)
  end

  def self.migrate_all
    puts "cooperatives: #{ self.count }"
    self.all.each &:migrate
    # add 1000 to create space between legacy data and new data
    ::Organization.connection.execute("SELECT setval('organizations_id_seq', (SELECT MAX(id) FROM organizations)+1000)")
  end

  def self.purge_migrated
    puts "Organization.destroy_all"
    ::Organization.destroy_all
  end


end

end
