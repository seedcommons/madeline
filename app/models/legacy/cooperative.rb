# -*- SkipSchemaAnnotations
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
        name: name.try(:strip),
        legal_name: nombre_legal_completo.try(:strip),
        primary_phone: telephone.try(:strip),
        email: email.try(:strip),
        street_address: address.try(:strip),
        city: city.try(:strip),
        neighborhood: borough.try(:strip),
        state: state.try(:strip),
        country_id: Country.id_from_name(self.country),
        tax_no: tax_id.try(:strip),
        #todo: figure out why this bombs, perhaps because source column is already lower case
        #website: web,
        alias: self.alias.try(:strip),
        sector: sector.try(:strip),
        industry: industry.try(:strip),
        referral_source: source.try(:strip),
        is_recovered: (recuperada == 1)
    }
    data
  end

  def migrate
    data = migration_data
    puts "#{data[:id]}: #{data[:name]}"
    existing = Organization.find_by(id: data[:id])
    if existing
      existing.update(data)
    else
      ::Organization.create(data)
    end
  end

  def self.migrate_all
    puts "cooperatives: #{ self.count }"
    self.all.each &:migrate
    # add 1000 to create space between legacy data and new data
    ::Organization.recalibrate_sequence(gap: 1000)
  end

  def self.purge_migrated
    puts "Organization.destroy_all"
    ::Organization.destroy_all
  end


end

end
