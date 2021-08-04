# Madeline

## Requirements
* ruby 2.2.x
* postgresql
* mysql (for migrating legacy data)
* PhantomJS 2.1.x or higher
* ImageMagick for image processing
* Redis for Sidekiq job queue

## Getting Started
    git clone git@github.com:sassafrastech/madeline_system.git
    cd madeline_system
    bundle install
    cp config/database.yml.example config/database.yml
    nano config/database.yml
    cp config/secrets.yml.example config/secrets.yml
    nano config/secrets.yml
    cp .env.example .env
    nano .env
    rake db:create && rake db:schema:load && rake db:seed  # db:setup fails for some reason, use this instead
    rake dev:fake_data
    rails s

### Creating a test user from the rails console
    Person.create(division_id: 99, email: 'test@theworkingworld.org', first_name: 'Test', has_system_access: true, password: 'test1234', password_confirmation: 'test1234', access_role: 'admin')

### Background Jobs

Some things, including connecting to Quickbooks, loan health checks, and email require background jobs to be running.

To run jobs, you'll need to start redis.
Then run `bundle exec sidekiq` from the project directory

### Testing mailers

To test sending mail, install and run mailcatcher, then run background jobs with sidekiq:

```
gem install mailcatcher
mailcatcher
bundle exec sidekiq
```

## Data migration

It's better to run the main data migration on a local machine to preserve scarce CPU time on the server. If we use too much CPU, we get severely throttled.

1. Get latest dump from `base` on `cofunder.theworkingworld.org`
2. Extract into local MySQL db specified in `legacy` connection in `database.yml`
3. `rake db:reset` – destroys all data!
4. `rake tww:migrate_all` (takes about half an hour)

To copy to server:

1. ``pg_dump -cOxd madeline_system_development > madeline_system_development-`date +%Y-%m-%d`.sql``
2. Copy dump file to server

On server:

1.  `cd /var/www/rails/madeline/staging/current` or `cd /var/www/rails/madeline/production/current`
2.  `export RAILS_ENV=staging` or `export RAILS_ENV=production`
3.  `rake db:create`  if db doesn't exist
4.  `rake db:schema:load` – destroys all data!
5.  `rails db < /path/to/dumpfile.sql`
6.  Then run media and document migration below on server

### Media Migration

1.  Get the latest media files onto server at `/var/www/rails/madeline/shared/legacymedia`.

    1.  The old media files can be found on `cofunder.theworkingworld.org` at `/var/www/internal.labase.org/linkedMedia`.

    2.  Use the following command on the new server to sync the latest media changes:

        ```
        rsync -hrv adamk@cofunder.theworkingworld.org:/var/www/internal.labase.org/linkedMedia /var/www/rails/madeline/shared/legacymedia
        ```

2.  Run `df -h` to check the free space on the server. The media files take up about 9GB. You'll probably have to delete the previously migrated files (everything in `shared/public/uploads`) before running the media migration command below.

3.  ```
    sudo -u deploy RAILS_ENV={stage} LEGACY_MEDIA_BASE_PATH=/var/www/rails/madeline/shared/legacymedia rake tww:migrate_media
    ```

### Document Migration

1.  Get the latest document files onto server at `/var/www/rails/madeline/shared/legacymedia`.

    1.  The old document files can be found on `cofunder.theworkingworld.org` at `/var/www/internal.labase.org/documents` and `/var/www/internal.labase.org/contracts`.

    2.  Use the following commands on the new server to sync the latest changes:

        ```
        rsync -hrv adamk@cofunder.theworkingworld.org:/var/www/internal.labase.org/documents /var/www/rails/madeline/shared/legacymedia
        rsync -hrv adamk@cofunder.theworkingworld.org:/var/www/internal.labase.org/contracts /var/www/rails/madeline/shared/legacymedia
        ```

2.  ```
    sudo -u deploy RAILS_ENV={stage} LEGACY_DOCUMENT_BASE_PATH=/var/www/rails/madeline/shared/legacymedia rake tww:migrate_files
    ```

## QuickBooks Configuration

### Set up Madeline test database
1. Run `rake dev:db_reset`. (This deletes all data and creates fake data.)
2. Sign in with the admin user. Credentials appear in the console when the above rake command is run.

At this time, Madeline only supports accounting with the quickbooks app set up by Sassafras.

### Open QuickBooks sandbox
1. Log into Intuit Developer account associated with the project (talk to team for information)
1. Go to Sandbox (under Account dropdown). It may take a moment to load.
1. You will see sandbox companies. Click `Go to company` for the one you want to use.
1. A new window will open for a sandbox version of QuickBooks.

#### Adjust company account settings
1. Follow *Open QuickBooks sandbox*, if you are not inside QuickBooks.
1. Click on the gear icon to the upper right.
1. Click on `Company Settings`.
1. Inside the `Advanced` tab, scroll to the `Categories` section. Click the pencil icon.
1. Make sure `Track classes` is enabled with `One to each row in transaction` selected in `Assign classes`.
1. Make sure `Track locations` is enabled with `Location label` set to `Division`.

#### Set Up Required Class

1. Follow *Open QuickBooks sandbox*, if you are not inside QuickBooks.
1. Click on the gear icon to the upper right.
1. Click on `All Lists` under the `Lists` section.
1. Click on `Classes`.
1. Click `New` to open the new class form.
1. In the form, add `Loan Products` inside the `Name` field.
1. Click `Save`.

#### Create QuickBooks accounts inside the app's sandbox
1. Follow *Open QuickBooks sandbox*, if you are not inside QuickBooks.
1. Click on `Accounting` in the menu to the right.
1. Click on `New`.
1. A new account modal pops up.
1. Create the following accounts, if not existing.

<table>
  <thead>
    <th>Category Type</th>
    <th>Detail Type</th>
    <th>Name</th>
  </thead>
  <tbody>
    <tr>
      <td>Accounts receivable</td>
      <td>Accounts receivable</td>
      <td>Loans Receivable</td>
    </tr>
    <tr>
      <td>Accounts receivable</td>
      <td>Accounts receivable</td>
      <td>Interest Receivable</td>
    </tr>
    <tr>
      <td>Income</td>
      <td>Service/Fee Income</td>
      <td>Interest Income</td>
    </tr>
  </tbody>
</table>

### Connect the QuickBooks app to Madeline

#### Connect API keys
1. Follow the steps in *Open your Intuit Developer app*.
1. Inside the project dashboard, click on the `Keys` tab.
1. Copy the OAuth Consumer Key and OAuth Consumer Secret into your `.env` file inside your Madeline environment. Use `.env.example` as a template.

#### Authorize redirect URI for your development environment
Oauth2 on Quickbooks requires that redirect URIs be whitelisted. So far, we have had the most luck with setting up our development server to use https and a domain name like madeline.test.
1. In the Quickbooks development interface, navigate to the app, then to Development - Keys & Oauth2.
1. Under redirect URIs, add your development uri followed by `/admin/accounting-settings` (e.g. `https://madeline.test/admin/accounting-settings`)
1. Note: alternatively you can configure your local server to use `https://madeline.test/admin/accounting-settings` which is already authorized.
1. Note: redirect URIs for production, rather than development or sandbox, qb companies must also have a real top level domain.

#### Authorize Madeline and QuickBooks connection
1. In your Madeline environment, you must be set up for background jobs (see main README)
   1. If this is not set up, your QuickBooks data import will always be 'pending.'
1. In your Madeline environment click `Manage > Accounting Settings` in the main menu.
1. Click the `Connect to QuickBooks` button. A popup opens.
1. Sign into your Intuit Developer account.
1. Choose a sandbox company to connect to.
1. Click the `Authorize` button to share data between QuickBooks and Madeline.
1. A message should appear from Madeline that you can now close the window.
1. Close the window. Refresh the main Madeline window. The QuickBooks settings page should show `QuickBooks Status`
as `Connected`, and `Quickbooks Data Import` as `in progress`. Refresh until you see it has succeeded.

#### Connect QuickBooks Accounts
1. Follow the steps in the *Create QuickBooks accounts inside the app's sandbox* section above, if you have not done so already.
1. Visit the Madeline Setting page at `Manage > Accounting Settings`.
1. Click `Connect to Quickbooks` if you have not done so recently.
1. Refresh Accounting Settings page until you see that the quickbooks import has succeeded.
1. See the `QuickBooks Accounts` section lower on the page.
1. Change the three account values to the following:
   1. Principal Account: Loans Receivable
   1. Interest Receivable Account: Interest Receivable
   1. Interest Income Account: Interest Income
1. Click `Save`. A successfully updated flash message will appear.

#### Switching between sandbox and actual quickbooks companies on your local development environment:
1. For sandbox, you can log into an existing Intuit Developer account with the Madeline development credentials (in lastpass) to access existing sandbox companies.
1. Make sure you have the correct oauth consumer key and oauth consumer secret set in your .env file. For example, the sandbox variables are QB_SANDBOX_OAUTH_CONSUMER_KEY
1. Also in your .env file, set the QB_SANDBOX_MODE to 1 to use sandbox and 0 to use actual quickbooks companies
1. Ask a team member for values for the consumer key and consumer secret if needed.

## Installing and Running Redis

### Install Redis

1. If using a Mac, `brew install redis`.

### Run Redis

1. Run `redis-server`.
