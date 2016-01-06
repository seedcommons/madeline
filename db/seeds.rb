# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Division.find_or_create_by({id:Division.root_id, name:'Root Division'})
Division.connection.execute("select setval('divisions_id_seq', greatest((select max(id)+1 from divisions), #{Division.root_id+1}))")


Language.find_or_create_by({id:1,name:'English',code:'EN'})
Language.find_or_create_by({id:2,name:'Español',code:'ES'})
Language.connection.execute("select setval('languages_id_seq', (select max(id) from languages))")

