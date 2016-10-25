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
    rake db:setup
    rake dev:fake_data
    rails s

### Creating a test user from the rails console
    Person.create(division_id: 99, email: 'test@theworkingworld.org', first_name: 'Test', has_system_access: true, password: 'test1234', password_confirmation: 'test1234', owning_division_role: 'admin')

## Data migration
It's better to run the main data migration on a local machine to preserve scarce CPU time on the server. If we use too much CPU, we get severely throttled.

1. Get latest dump from `base` on `cofunder.theworkingworld.org`
2. Extract into local MySQL db specified in `legacy` connection in `database.yml`
3. `rake db:schema:load` – destroys all data!
4. `rake tww:migrate_all` (takes about half an hour)

To copy to server:

1. ``pg_dump -cOxd madeline_system_development > madeline_system_development-`date +%Y-%m-%d`.sql``
2. Copy dump file to server

On server:

1.  `cd /var/www/rails/madeline/staging/current`
2.  `export RAILS_ENV=staging` (or `production`)
3.  `rake db:create`  if db doesn't exist
4.  `rake db:schema:load` – destroys all data!
5.  `rails db`
6.  `\i /path/to/dumpfile.sql`
7.  Then run media migration below on server

### Media Migration

1.  Get the latest media files onto server at `/var/www/rails/madeline/staging/shared/legacymedia`.

    1.  The old media files can be found on `cofunder.theworkingworld.org` at `/var/www/internal.labase.org/linkedMedia`.

    2.  Use the following command on the old server to sync the latest media changes:

        ```shell
        rsync -hrv /var/www/internal.labase.org/linkedMedia deploy@ms-staging.theworkingworld.org:/var/www/rails/madeline/staging/shared/legacymedia
        ```

2.  Run `df -h` to check the free space on the server. The media files take up about 9GB. You'll probably have to delete the previously migrated files (in `shared/public/uploads`) before running the media migration command below.

3.  ```shell
    sudo -u deploy RAILS_ENV=staging LEGACY_MEDIA_BASE_PATH=/var/www/rails/madeline/staging/shared/legacymedia rake tww:migrate_media
    ```
