# Madeline Accounting Features
## Manual Testing Protocol

### Setup

1. `rake dev:db_reset` (Deletes all data and creates fake data)
2. Sign in with admin user (admin@example.com, xxxxxxxx)

#### Accounting system setup

1. Create a QB developer account and obtain token if you haven't already (see README.md)
2. In QB create accounts if not existing:
    1. Interest Receivable (Type: Accounts receivable)
    2. Loans Receivable (Type: Accounts receivable)
    3. Interest Income (Type: Income)


### Create an Intuit Developer account

In order to test any of the QuickBooks features, you will need to create an Intuit Developer account and sandbox.

1. Visit https://developer.intuit.com
1. Click "Sign In"
1. Create an account, or sign in
1. Click on "My Apps"
1. Click on "Select APIs" under "Just start coding"
1. Select "Accounting" and click "Create app"
1. Click on "Keys"
1. Copy the OAuth Key and Secret into your .env file. Use `.env.example` as a template.
1. While logged into the application (Madeline site), visit Manage > Settings.
1. Click on the button that says "Connect to QuickBooks."
1. Sign in to the QuickBooks account for your developer account.
1. Click authorize to connect your account data to Madeline.

Refer to http://minimul.com/integrating-rails-and-quickbooks-online-via-the-version-3-api-part-1.html if any steps are missing..

### Accounting

1. Connect to QuickBooks
  1. In Madeline click `Manage > Settings` in the main menu.
  1. Click the `Connect to QuickBooks` button. (A popup shows.)
  1. Sign into your Intuit Developer account.
  1. Click the `Authorize` button to share data between QuickBooks and Madeline.
  1. A message should appear from Madeline that you can now close the window.
  1. Close the window. Refresh the main browser. The QuickBooks settings page should show `QuickBooks Status`
as `Connected`.
  1. Click `Full Sync`. Once completed, a message will flash indicating that QuickBooks data has been synchronized.

1. Connect QuickBooks Accounts
  1. TODO: These instructions below are incomplete. Sometimes the account names listed below do not exist. Also, some explanation about what these accounts are would be helpful. Do accounts need to be created inside the QuickBooks Online interface first?
  1. Now we need to add accounts.
  1. See the `QuickBooks Accounts` section lower on the Madeline page.
  1. Change three account values:
    1. Principal Account: Loans Receivable
    1. Interest Receivable Account: Interest Receivable
    1. Interest Income Account: Interest Income
  1. Click `Save`. (Flash message: successfully updated)

4. Loan Transactions
    1. Click 'Loans' from nav menu and choose a loan with no transactions from the table.
    2. Note the number in the Rate field.
    2. Click 'Transactions' tab. ("No records" message)
    3. Click 'Add Transaction'
        1. Type: Disbursement
        2. Date: Today (default)
        3. Bank Acct: Any
        4. Amount: 100
        5. Description: Default is fine
        6. Memo: Random text
        7. Click 'Add' (Txn shows in table, Flash message: successfully created)
    4. Click 'Add Transaction'
        1. Type: Repayment
        2. Date: One year from now
        3. Bank Acct: Any
        4. Amount: 50
        5. Click 'Add' (Txn shows in table, int txn also shows on same day before repayment, appropriate value)
        6. View values for int/prin ∆s and totals in table (Should be all present and reasonable)
    5. Go to QB > Gear Icon > All Lists > Classes
        1. Find loan ID and click 'Run Report'
        2. Ignore Balance column
        2. Click any line item from disbursement transaction
            1. View line items (Correct amounts, accounts, description, class, location, name)
            2. View correct memo
            4. Exit Journal Entry view
        5. Click any line item from interest transaction
            1. View line items (Correct amounts, accounts, description, class, location, name)
            2. Exit Journal Entry view
        7. Click any line item from repayment transaction
            1. View line items (Correct amounts, accounts, description, class, location, name)
            2. View correct memo
            3. Exit Journal Entry view
    6. Edit disbursement in QB
        1. Change both disbursement line item amounts to 110
    7. Go back to Madeline and reload txn page of the loan (this should recalculate interest and send back to QBO)
    8. Refresh the page (runs updater again, nothing should change)
    9. Go back to QBO and see that interest txn has updated, repayment updated also (line items)
