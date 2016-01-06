# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Division.find_or_create_by({id:Division.root_id, name:'Root Division'})
# note, the +1 is technically unnecessary, but i wanted new divisions to start at 101 instead of 100
Division.connection.execute("select setval('divisions_id_seq', greatest((select max(id)+1 from divisions), #{Division.root_id+1}))")


Language.find_or_create_by({id:1,name:'English',code:'EN'})
Language.find_or_create_by({id:2,name:'Español',code:'ES'})
Language.connection.execute("select setval('languages_id_seq', (select max(id) from languages))")


Currency.find_or_create_by({id:1,name:'Argentinean Peso',code:'ARS',symbol:'AR$'})
Currency.find_or_create_by({id:2,name:'U.S. Dollar',code:'USD',symbol:'US$'})
Currency.find_or_create_by({id:3,name:'British Pound',code:'GBP',symbol:'£'})
Currency.find_or_create_by({id:4,name:'Nicaraguan Cordoba',code:'NIO',symbol:'NI$'})
Currency.connection.execute("select setval('currencies_id_seq', (select max(id) from currencies))")


Country.find_or_create_by({id:1,name:'Argentina',iso_code:'AR',default_language_id:2,default_currency_id:1})
Country.find_or_create_by({id:2,name:'Nicaragua',iso_code:'NI',default_language_id:2,default_currency_id:4})
Country.find_or_create_by({id:3,name:'United States',iso_code:'US',default_language_id:1,default_currency_id:2})
Country.connection.execute("select setval('countries_id_seq', (select max(id) from countries))")
