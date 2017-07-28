# Madeline

## Requirements
* ruby 2.2.x
* postgresql
* mysql (for migrating legacy data)
* PhantomJS 2.1.x or higher

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
    Person.create(division_id: 99, email: 'test@theworkingworld.org', first_name: 'Test', has_system_access: true, password: 'test1234', password_confirmation: 'test1234', owning_division_role: 'admin')

### Delayed job

Some things, like loan health checks, require delayed_job to be running. Run delayed_job with `bin/delayed_job start`.

### Testing mailers

To test sending mail, install and run mailcatcher, then run delayed_job:

```
gem install mailcatcher
mailcatcher
bin/delayed_job start
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

### Quickbooks configuration

In order to test any of the Quickbooks features, you will need to create Intuit Developer account and sandbox.

#### Set up an Intuit Developer account
1. Visit https://developer.intuit.com
1. Click "Sign In"
1. Create an account, or sign in
1. Click on "My Apps"
1. Click on "Select APIs" under "Just start coding"
1. Select "Accounting" and click "Create app"
1. Click on "Keys"
1. Copy the OAuth Key and Secret into your .env file. Use `.env.example` as a template.
1. While logged into the application (Madeline site), visit Manage > Settings.
1. Click on the button that says "Connect to Quickbooks."
1. Sign in to the Quickbooks account for your developer account.
1. Click authorize to connect your account data to Madeline.

Refer to http://minimul.com/integrating-rails-and-quickbooks-online-via-the-version-3-api-part-1.html if any steps are missing..

#### Add disbursement

##### Prepare your QuickBooks account
1. In order to add a disbursement transaction, a QuickBooks account must be properly set up.
1. If you are working with a QuickBooks account with real data:
  1. Log into your QuickBooks account.
1. If you are working with a QuickBooks account for testing or development:
  1. Follow the steps above in "Set up an Intuit Developer account" to create a QuickBooks account and connect it to Madeline.
  1. Inside "Intuit Developer > My Apps", click on your app.
  1. Inside "Resources" section, click on "QuickBooks sandbox".
  1. Click "Go to company".
1. Inside QuickBooks, click on the gear icon for settings. Under "Settings", click on "Company Settings". (For example, https://sandbox.qbo.intuit.com/app/settings?p=Company.)
1. In the "Company" section of the "Company Settings", scroll to the "Categories" section.
1. Click the pencil icon to edit the "Categories" section.
1. Make sure "Track Classes" is checked/on.
1. Make sure "Track Locations" is checked/on.
1. In the "Location label" dropdown, select "Divisions".
1. Click the "Save" button.

##### Adjust QuickBooks settings

1. Inside Madeline, in the main menu, go to "Manage > Settings".
1. Ensure that the QuickBooks account you wish to use is connected.
1. Click on "Full Sync".
1. In the "QuickBooks Accounts" settings below, select 3 separate accounts.
  1. Principal Account: Funds will be disbursed from the principal account.
  1. Specific accounts in QuickBooks cannot be used as the 3 main QuickBooks accounts specified in "QuickBooks Accounts" in your Madeline settings. If you encounter an error when trying to add a disbursement, please try selecting a different account in your "QuickBooks Accounts" settings.

##### Add a disbursement transaction

1. When you are ready to add a disbursement to a specific loan, visit the loan in Madeline. (For example, http://http://localhost:3000/admin/loans/{loan-id})
1. Click on the "Transactions" tab.
1. Click on the "Add Transaction".
1. A modal will appear.
1. In "Type of Transaction", select "Disbursement".
1. In "Bank Account", select the bank account that the funds will be disbursed into. Funds will come from the primary account and be disbursed into this account.
1. Select an amount.
1. Revise the other transaction form fields, as desired.
1. Save.
1. The page will reload and display your transaction.
1. If an error is shown instead of the page reloading, there may be a problem your QuickBooks settings. Please see "Adjust QuickBooks settings"
