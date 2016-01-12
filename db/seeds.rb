# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# the '99' is to make sure we leave space for the migrated divisions
Division.find_or_create_by(id: 99, internal_name: Division.root_internal_name, name:'Root Division')
# note, divisions created within the new system will start at 101
Division.connection.execute("select setval('divisions_id_seq', greatest((select max(id) from divisions), 100))")


Language.find_or_create_by(id: 1, name: 'English', code: 'EN')
Language.find_or_create_by(id: 2, name: 'Español', code: 'ES')
Language.find_or_create_by(id: 3, name: 'Français', code: 'FR')
Language.connection.execute("select setval('languages_id_seq', (select max(id) from languages))")


Currency.find_or_create_by(id: 1, name: 'Argentinean Peso', code: 'ARS', symbol: 'AR$')
Currency.find_or_create_by(id: 2, name: 'U.S. Dollar', code: 'USD', symbol: 'US$')
Currency.find_or_create_by(id: 3, name: 'British Pound', code: 'GBP', symbol: 'GB£')
Currency.find_or_create_by(id: 4, name: 'Nicaraguan Cordoba', code: 'NIO', symbol: 'NI$')
Currency.connection.execute("select setval('currencies_id_seq', (select max(id) from currencies))")


Country.find_or_create_by(id: 1, name: 'Argentina', iso_code: 'AR', default_language_id: 2, default_currency_id: 1)
Country.find_or_create_by(id: 2, name: 'Nicaragua', iso_code: 'NI', default_language_id: 2, default_currency_id: 4)
Country.find_or_create_by(id: 3, name: 'United States', iso_code: 'US', default_language_id: 1, default_currency_id: 2)
Country.connection.execute("select setval('countries_id_seq', (select max(id) from countries))")


# for now mapping the '0' Person refs to 'null' and allowing null refs in the schema
# Person.find_or_create_by({id:0, name: 'dummy', first_name: 'dummy', division_id: Division.root_id})


loan_status = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name, model_attribute: 'status')
# beware rerunning these different position values, will result in duplicated data
# a more verbose approach would be needed if that is important to support
# also we can consider dropping the 'position' assignments until an ordering different than 'value' is needed
loan_status.options.find_or_create_by(value: 1, position: 1).set_label_list(en: 'Active', es: 'Prestamo Activo')
loan_status.options.find_or_create_by(value: 2, position: 2).set_label_list(en: 'Completed', es: 'Prestamo Completo')
loan_status.options.find_or_create_by(value: 3, position: 3).set_label_list(en: 'Frozen', es: 'Prestamo Congelado')
loan_status.options.find_or_create_by(value: 4, position: 4).set_label_list(en: 'Liquidated', es: 'Prestamo Liquidado')
loan_status.options.find_or_create_by(value: 5, position: 5).set_label_list(en: 'Prospective', es: 'Prestamo Prospectivo')
loan_status.options.find_or_create_by(value: 6, position: 6).set_label_list(en: 'Refinanced', es: 'Prestamo Refinanciado')
loan_status.options.find_or_create_by(value: 7, position: 7).set_label_list(en: 'Relationship', es: 'Relacion')
loan_status.options.find_or_create_by(value: 8, position: 8).set_label_list(en: 'Relationship Active', es: 'Relacion Activo')


loan_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name, model_attribute: 'loan_type')
loan_type.options.find_or_create_by(value: 1, position: 1).
    set_label_list(en: 'Liquidity line of credit', es: 'Línea de crédito de efectivo')
loan_type.options.find_or_create_by(value: 2, position: 2).
    set_label_list(en: 'Investment line of credit', es: 'Línea de crédito de inversión')
loan_type.options.find_or_create_by(value: 3, position: 3).
    set_label_list(en: 'Investment Loans', es: 'Préstamo de Inversión')
loan_type.options.find_or_create_by(value: 4, position: 4).
    set_label_list(en: 'Evolving loan', es: 'Préstamo de evolución')
loan_type.options.find_or_create_by(value: 5, position: 5).
    set_label_list(en: 'Single Liquidity line of credit', es: 'Línea puntual de crédito de efectivo')
loan_type.options.find_or_create_by(value: 6, position: 6).
    set_label_list(en: 'Working Capital Investment Loan', es: 'Préstamo de Inversión de Capital de Trabajo')
loan_type.options.find_or_create_by(value: 7, position: 7).
    set_label_list(en: 'Secured Asset Investment Loan', es: 'Préstamo de Inversión de Bienes Asegurados')


