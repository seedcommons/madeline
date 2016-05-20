# The Madeline System

## Requirements
* ruby 2.2.x
* postgresql
* mysql (for migrating legacy data)

## Getting Started
    git clone git@github.com:sassafrastech/madeline_system.git
    cd madeline_system
    bundle install
    cp config/database.yml.example config/database.yml
    emacs config/database.yml
    cp config/secrets.yml.example config/secrets.yml
    emacs config/secrets.yml
    rake db:drop db:setup
    rake dev:fake_data
    rails s

### Creating a test user from the rails console
    Person.create(division_id: 99, email: 'jfe@pobox.com', first_name: 'jfe', has_system_access: true, password: 'xxxxxxxx', password_confirmation: 'xxxxxxxx', owning_division_role: 'admin')