# This is generic data that is needed for any instance of this app to work properly.
# It should not be specific to a particular instance.

root_div = Division.find_or_initialize_by(id: 99)
root_div.assign_attributes(name: 'Root Division', short_name: 'root-division')
root_div.save!


Currency.find_or_create_by(id: 1, name: 'Argentinean Peso', code: 'ARS', symbol: 'AR$',
  short_symbol: '$', country_code: 'AR')
Currency.find_or_create_by(id: 2, name: 'U.S. Dollar', code: 'USD', symbol: 'US$',
  short_symbol: '$', country_code: 'US')
Currency.find_or_create_by(id: 3, name: 'British Pound', code: 'GBP', symbol: 'GB£',
  short_symbol: '£', country_code: 'GB')
Currency.find_or_create_by(id: 4, name: 'Nicaraguan Cordoba', code: 'NIO', symbol: 'NIC$',
  short_symbol: 'C$', country_code: 'NI')
Currency.find_or_create_by(id: 5, name: 'Mexican Peso', code: 'MXN', symbol: 'MX$',
  short_symbol: '$', country_code: 'MX')

Country.find_or_create_by(id: 1, name: 'Argentina', iso_code: 'AR', default_currency_id: 1)
Country.find_or_create_by(id: 2, name: 'Nicaragua', iso_code: 'NI', default_currency_id: 4)
Country.find_or_create_by(id: 3, name: 'United States', iso_code: 'US', default_currency_id: 2)
Country.find_or_create_by(id: 4, name: 'Mexico', iso_code: 'MX', default_currency_id: 5)


OptionSetCreator.new.find_or_create_all

puts 'completed seeding the database'
