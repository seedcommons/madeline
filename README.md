# Madeline

## Requirements
* ruby 2.2.x
* postgresql
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

## Translations

Translation management is done using Transifex. See the `bin/pull_translations` and `bin/push_translations`
scripts. The Transifex `tx` command line client is needed. See https://docs.transifex.com/client/installing-the-client
for installation instructions.

Once the client is installed, obtain a token at https://www.transifex.com/user/settings/api/.
Add it to your .bashrc/.zshrc/whatever like so:

    export TX_TOKEN=<your_Transifex_API_token>

To push translations to Transifex, run

    bin/push_translations

This combines all the *.en.yml files in the project into one temporary file and uploads them.
We do it this way to make the translator's job easier as they only have to translate one resource.

To pull the latest translations from Transifex run

    bin/pull_translations

and commit any changes.


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
