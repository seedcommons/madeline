# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# the '99' is to make sure we leave space for the migrated divisions
Division.find_or_create_by({id:99, internal_name: Division.root_internal_name, name:'Root Division'})
# note, divisions created within the new system will start at 101
Division.connection.execute("select setval('divisions_id_seq', greatest((select max(id) from divisions), 100))")

# note, these hardcoded id's are needed to match the migrated data
Language.find_or_create_by({id:1,name:'English',code:'EN'})
Language.find_or_create_by({id:2,name:'Español',code:'ES'})
Language.find_or_create_by({id:3,name:'Français',code:'FR'})
Language.connection.execute("select setval('languages_id_seq', (select max(id) from languages))")


# note, these hardcoded id's are needed to match the migrated data
Currency.find_or_create_by({id:1,name:'Argentinean Peso',code:'ARS',symbol:'AR$'})
Currency.find_or_create_by({id:2,name:'U.S. Dollar',code:'USD',symbol:'US$'})
Currency.find_or_create_by({id:3,name:'British Pound',code:'GBP',symbol:'GB£'})
Currency.find_or_create_by({id:4,name:'Nicaraguan Cordoba',code:'NIO',symbol:'NI$'})
Currency.connection.execute("select setval('currencies_id_seq', (select max(id) from currencies))")


# note, these hardcoded id's are needed to match the migrated data
Country.find_or_create_by({id:1,name:'Argentina',iso_code:'AR',default_language_id:2,default_currency_id:1})
Country.find_or_create_by({id:2,name:'Nicaragua',iso_code:'NI',default_language_id:2,default_currency_id:4})
Country.find_or_create_by({id:3,name:'United States',iso_code:'US',default_language_id:1,default_currency_id:2})
Country.connection.execute("select setval('countries_id_seq', (select max(id) from countries))")

# for now mapping the '0' Person refs to 'null' and allowing null refs in the schema
# Person.find_or_create_by({id:0, name: 'dummy', first_name: 'dummy', division_id: Division.root_id})



# note, the assigned id values correspond to the 'active' column in the legacy LoanQuestions table
#todo: restore this version once optionset branch merged
# CustomFieldSet.find_or_create_by(id: 1, division: Division.root, internal_name: 'loan_criteria').set_label_list(en: 'Loan Criteria Questionnaire')
# CustomFieldSet.find_or_create_by(id: 3, division: Division.root, internal_name: 'loan_post_analysis').set_label_list(en: 'Loan Post Analysis')
# CustomFieldSet.find_or_create_by(id: 1, division: Division.root, internal_name: 'bogus').set_label('?Bogus Loan Criteria Questionnaire')
CustomFieldSet.find_or_create_by(id: 2, division: Division.root, internal_name: 'loan_criteria-2').set_label('Loan Criteria Questionnaire')
CustomFieldSet.find_or_create_by(id: 3, division: Division.root, internal_name: 'loan_post_analysis').set_label('Loan Post Analysis')
#todo: find somplace to factor this out to
CustomFieldSet.connection.execute("select setval('custom_field_sets_id_seq', (select max(id) from custom_field_sets))")

