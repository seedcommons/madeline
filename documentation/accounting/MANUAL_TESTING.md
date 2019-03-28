# Madeline Accounting Features
## Manual Testing Protocol

## Set up
Manage -> Account Settings
Connect to Quickbooks
Use madelineqb@sassafras.coop, pwd in lastpass
Connect to "Madeline Staging Test Company" in Quickbooks (NEVER to TWW qb)

Set "Principal Account" To Loans Receivable. 
Set "Interest Receivable Account" to Interest Receivable
Set "Interest Income Account" to Interest Income

## Features
### Loan Transactions
  1. Inside Madeline, click `Loans` from the main menu and choose a loan with no transactions from the table.
     1. A loan with no transactions will not show a list of transactions in the `Transactions` tab (when viewing a specific loan).
  1. Click on the loan you want to open. The loan's `Details` tab is initially shown.
  1. Note the number in the `Rate` field in the loan's `Details`.
  2. Click the `Transactions` tab.

#### Add Disbursement
  1. Click 'Add Transaction'
     1. Type: Disbursement
     1. Date: Today (default)
     1. Bank Acct: any Asset account (e.g. La Base 1527 when using TWW data)
     1. Amount: 100
     1. Description: Default is fine
     1. Memo: Random text
     1. Click 'Add'
  1. One newly created transaction should show up in the table. Flash message: successfully created.

#### Add Repayment
  1. Click 'Add Transaction'
     1. Type: Repayment
     1. Date: One year from now
     1. Bank Acct: any Asset account (e.g. La Base 1527 when using TWW data)
     1. Amount: 50
     1. Click 'Add'
  1. The page will refresh.
  1. One newly created transaction shows in the table. The type will show up as "Repayment."
  1. One newly created interest transaction also shows on the same day listed above the repayment line with the appropriate value. The type will show up as "Interest."

#### Interest and principal changes and totals show in table
  1. View values for interest/principal ∆s and totals in table. Values should be all present and reasonable.

#### Confirm transactions are sent to QuickBooks
  1. In Madeline, note the loan id number in the address bar or in loan details for the loan that now has transactions.
  1. Go to your Intuit Developer account QuickBooks sandbox.
  1. Inside your QB sandbox, click Gear Icon > All Lists > Classes
     1. Find the loan ID and click 'Run Report'
     1. Ignore Balance column
     1. Click any line item from disbursement transaction
        1. View line items (Correct amounts, accounts, description, class, location, name)
        1. View correct memo
        1. Exit Journal Entry view
     1. Click any line item from interest transaction
        1. View line items (Correct amounts, accounts, description, class, location, name)
        1. Exit Journal Entry view
     1. Click any line item from repayment transaction
        1. View line items (Correct amounts, accounts, description, class, location, name)
        1. View correct memo
        1. Exit Journal Entry view

#### Edit disbursement inside QB
  1. Change both disbursement line item amounts to 110
  1. Go back to Madeline and reload the txn page of the loan (this should recalculate interest and send back to QBO)
  1. Refresh the page (runs updater again, nothing should change)
  1. Go back to QBO and see that interest txn has updated, repayment updated also (line items)

#### Special cases
  1. If you update the quickbooks test data (see below), quickbooks entities created in testing (customers, transactions, etc) will be deleted. When loading transactions, you may see errors like "There was an error communicating with QuickBooks. An administrator has been notified. Some data may be out of date. (Error: Invalid Reference Id: Invalid Reference Id : Customer assigned to this transaction has been deleted. Before you can modify this transaction, you must restore zecb98905 (deleted).)." In order to restore the customer:
     1. Navigate to Customers in Quickbooks. 
     1. Select the gear icon in the upper right of the Customers data area (not the gear in the main nav bar at the very top). Select 
     1. Select "Include inactive"
     1. Search for the id (e.g. zecb98905).
     1. Click on the customer, whose display name is the id (e.g. zecb98905). 
     1. Click "Make Active" in the upper right. This will make the edit button appear. 
     1. Click "Edit"
     1. Update the display name to be the name of the co-op in Quickbooks. You may be alerted that the name is already being used and asked if the customers should be merged. In this case, select "no" and add "(Customer)" to the end of the name. If similar happens with real data, TWW staff will need to manually combine the two customers in QB.  
     1. Reload transactions in Quickbooks. The error should be gone. 

#### How to update test quickbooks data
  1. For testing, we update the Madeline Staging Test Company in quickbooks with a copy of The Working World quickbooks.
  1. Log into Chronobooks (https://app.chronobooks.com/)
  1. Go to 'Copy' in the left hand side bar
  1. Click 'New Copy'
  1. You should see the 'copy from' company already set to The Working World.
  1. In the drop-down for 'copy to' select Madeline Staging Test Company
  1. Follow the steps to confirm and start the copy. It can take up to an hour to complete. 
