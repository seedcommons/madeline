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

### Accounting

1. Connect to Quickbooks
    1. In Madeline click Manage > Settings
    2. Click 'Quickbooks connect' buttton (Popup shows)
    3. Auth to QB (Message that you can now close window)
    4. Close window, refresh browser (Should show settings page with status connected)
    5. Click 'Full Sync' (Flash message: QB data synchronized)
    6. Change three account values:
        1. Principal Account: Loans Receivable
        2. Interest Receivable Account: Interest Receivable
        3. Interest Income Account: Interest Income
    7. Click 'Save' (Flash message: successfully updated)

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
