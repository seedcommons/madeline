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
        division_id: Legacy::Division.from_country(self.country).id,
        name: name.try(:strip),
        legal_name: nombre_legal_completo.try(:strip),
        primary_phone: telephone.try(:strip),
        email: email.try(:strip),
        street_address: address.try(:strip),
        city: city.try(:strip),
        neighborhood: borough.try(:strip),
        state: state.try(:strip),
        country_id: Country.find_by(name: self.country).try(:id),
        tax_no: tax_id.try(:strip),
        website: self[:web],
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
    # puts "#{data[:id]}: #{data[:name]}"
    organization = ::Organization.find_or_create_by(id: data[:id])
    organization.update(data)
  end

  def self.migrate_all
    puts "cooperatives: #{ self.count }"
    self.all.each &:migrate
    ::Organization.recalibrate_sequence
  end

  def self.purge_migrated
    puts "Organization.destroy_all"
    ::Organization.destroy_all
  end


end

end
