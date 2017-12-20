# Madeline Accounting Features
## Manual Testing Protocol

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
     1. Bank Acct: Any
     1. Amount: 100
     1. Description: Default is fine
     1. Memo: Random text
     1. Click 'Add'
  1. One newly created transaction should show up in the table. Flash message: successfully created.

#### Add Repayment
  1. Click 'Add Transaction'
     1. Type: Repayment
     1. Date: One year from now
     1. Bank Acct: Any
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
