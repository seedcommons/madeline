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
    rake db:schema:load # destroys all data!
    rake dev:fake_data
    rails s

### Creating a test user from the rails console
    Person.create(division_id: 99, email: 'test@theworkingworld.org', first_name: 'Test', has_system_access: true, password: 'test1234', password_confirmation: 'test1234', owning_division_role: 'admin')

## Data migration
It's better to run the main data migration on a local machine to preserve scarce CPU time on the server. If we use too much CPU, we get severely throttled.

1. Get latest dump from `base` on `cofunder.theworkingworld.org`
2. Extract into local MySQL db specified in `legacy` connection in `database.yml`
3. `rake db:schema:load` – destroys all data!
4. `rake tww:migrate_all`
5. ``pg_dump -cOxd madeline_system_development > madeline_system_development-`date +%Y-%m-%d`.sql``
6. Copy dump file to server

On server:

1.  `cd /var/www/rails/madeline/staging/current`
2.  `export RAILS_ENV=staging`
3.  `rake db:schema:load` – destroys all data!
4.  `rails db`
5.  `\i /path/to/dumpfile.sql`

### Media Migration

1.  If there have been media changes, get latest media files onto server at `/var/www/rails/madeline/staging/shared/legacymedia`
    1. Note: The server doesn't have much free space. If you're going to copy all the media files from the old server, you have to delete the previously migrated ones first (`legacymedia` and/or `shared/public/uploads`). After extracting the media, delete the zip file before running the media migration.
    2. Alternatively, something like `rsync` is probably a better solution.
2.  `df -h` – make sure there's at least 9GB available
3.  `sudo -u deploy RAILS_ENV=staging LEGACY_MEDIA_BASE_PATH=/var/www/rails/madeline/staging/shared/legacymedia rake tww:migrate_media`
