# Madeline Accounting Features
## Accounting Setup

### Set up Madeline test database
1. Run `rake dev:db_reset`. (This deletes all data and creates fake data.)
2. Sign in with the admin user. Credentials appear in the console when the above rake command is run.

### Set up a QuickBooks app

In order to test any of the QuickBooks features, you will need to create an Intuit Developer account and sandbox.

If any documentation is missing in this guide for setting up QuickBooks with Madeline, the following resources may be helpful:

* [Integrating Rails and QuickBooks Online](http://minimul.com/integrating-rails-and-quickbooks-online-via-the-version-3-api-part-1.html) by minimul
* [QuickBooks Online documentation](https://developer.intuit.com/docs/00_quickbooks_online/1_get_started/00_get_started) by Intuit Developer

#### Create or sign in to an Intuit Developer account
1. Visit the [Intuit Developer](https://developer.intuit.com/) site.
1. Click `Sign In` if you have an account or `Sign Up` if you don't have an account. Sign in or sign up.

#### Open your Intuit Developer app
1. While signed into Intuit Developer, click on `My Apps` in the main menu.
1. If you've already created an app for Madeline testing, click on the appropriate app. If not, continue to the *Create an Intuit Developer app* section below.
1. A dashboard for your project will appear after creating or opening your QuickBooks app.

#### Create an Intuit Developer app
1. Create an app if you have not already. Click on `Create new app.`
1. Click on `Select APIs` under `Just start coding`.
1. Select `Accounting` and click `Create app`.
1. A dashboard for your project will appear after creating the app.

### Open QuickBooks sandbox
1. Go to Sandbox (under Account dropdown). It may take a moment to load.
1. You will see a sandbox company. Click `Go to company`.
1. A new window will open for a sandbox version of QuickBooks.

#### Adjust Company account settings
1. Follow *Open QuickBooks sandbox*, if you are not inside QuickBooks.
1. Click on the gear icon to the upper right.
1. Click on `Company Settings`.
1. Inside the `Company` tab (default), scroll to the `Categories` section. Click the pencil icon.
1. Make sure `Track classes` is enabled with `One to each row in transaction` selected in `Assign classes`.
1. Make sure `Track locations` is enabled with `Location label` set to `Division`.


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
      <td>Interest Receivable</td>
    </tr>
    <tr>
      <td>Accounts receivable</td>
      <td>Accounts receivable</td>
      <td>Loans Receivable</td>
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
