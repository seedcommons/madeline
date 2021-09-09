# This is generic data that is needed for any instance of this app to work properly.
# It should not be specific to a particular instance.

root_div = Division.find_or_initialize_by(id: 99)
root_div.assign_attributes(name: 'Root Division', short_name: 'root-division')
root_div.save!

Division.recalibrate_sequence(gap: 1)

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
Currency.find_or_create_by(id: 6, name: 'Guatemalan Quetzal', code: 'GTQ', symbol: 'GTQ',
  short_symbol: 'Q', country_code: 'GT')
Currency.find_or_create_by(id: 7, name: 'South African Rand', code: 'ZAR', symbol: 'ZAR',
  short_symbol: 'R ', country_code: 'ZA')
Currency.find_or_create_by(id: 8, name: 'Indian Rupee', code: 'INR', symbol: 'IN₹',
  short_symbol: '₹', country_code: 'IN')
Currency.recalibrate_sequence

Country.find_or_create_by(id: 1, name: 'Argentina', iso_code: 'AR', default_currency_id: 1)
Country.find_or_create_by(id: 2, name: 'Nicaragua', iso_code: 'NI', default_currency_id: 4)
Country.find_or_create_by(id: 3, name: 'United States', iso_code: 'US', default_currency_id: 2)
Country.find_or_create_by(id: 4, name: 'Mexico', iso_code: 'MX', default_currency_id: 5)
Country.find_or_create_by(id: 5, name: 'Guatemala', iso_code: 'GT', default_currency_id: 6)
Country.find_or_create_by(id: 6, name: 'South Africa', iso_code: 'ZA', default_currency_id: 7)
Country.find_or_create_by(id: 7, name: 'India', iso_code: 'IN', default_currency_id: 8)
Country.recalibrate_sequence

OptionSetCreator.new.create_all

# Need to leave room for migrated questions
# Can remove this line once migration is over with.
Question.recalibrate_sequence(id: 300)

# Without these resets we were getting a strange closure_tree error.
QuestionSet.connection.schema_cache.clear!
QuestionSet.reset_column_information

QuestionSet.find_or_create_by(id: 2, internal_name: 'loan_criteria')
QuestionSet.find_or_create_by(id: 3, internal_name: 'loan_post_analysis')
QuestionSet.recalibrate_sequence(gap: 10)

puts 'seeds ran successfully'
