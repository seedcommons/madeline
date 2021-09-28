# Madeline Accounting Features

Madeline includes support for managing loan financial data with Quickbooks Online.

Detailed documentation of this functionality is found throughout the classes in the Accounting namespace.

## General Notes

* Quickbooks Online is considered the authoritative source for accounting data.
* Madeline's roles include:
    * Allowing easy viewing and editing of transaction data for a given Loan. In QuickBooks, the data is not easily viewable by loan.
    * Allowing easy creation of various types of standard transactions.
    * Computing interest and principal amounts for repayments according to Madeline's non-extractive interest formula.
    * Computing running interest and principal balances for a loan.
    * Recomputing and updating these amounts when transaction data changes from either Madeline or QuickBooks.

## Change Tracking

Changes to transactions in Madeline need to get pushed back to QuickBooks. There are currently several
ways for transactions to get created/updated on the Madeline side:

1. Creation via UI
2. Auto-creation of an interest transaction upon creation of a disbursement or repayment when there are transactions on previous days but no interest transaction
3. Modification via the interest calculation process

Any code that changes a transaction is responsible for setting the `needs_qb_push` flag on that transaction.
The TransactionReconciler then obeys this flag when considering whether to push a transaction to QuickBooks.

The flag defaults to `true`, and therefore if a transaction is getting created that doesn't
need pushing to QB (e.g. one that was just downloaded) the flag should be overridden.

## Sync Operation Flows

Following is a high-level sketch of how QB sync operations happen.

* TransactionsController#create/update/sync
    * [Error handling: Handles all kinds of Accounting::QB and Quickbooks API errors—always: rolls back DB txn, sets flash msg; sometimes: sets qb_not_connected, data_reset_required flags, notifies]
    * Updater#update(loan)
        * Delete global issues only
        * Updater#qb_sync_for_loan_update
        * Updater#update_loan(loan)
            * Delete loan issues only
            * extract_qb_data(loan)
            * InterestCalculator#recaculate(loan)
            * calculate_balances(loan)
* Successful QB authentication
    * FullFetcherJob
        * [Error handling: default for TaskJob (notify), set task status]
        * FullFetcher#fetch_all
            * [Error handling: destroy connection, delete QB data, clear division accounts object and re-raise]
            * Delete all issues
            * => QuickbooksUpdateJob (all loans)
* 'Fetch Changes' Link on accounting settings page
    * => QuickbooksUpdateJob (changed loans only)
* QuickbooksUpdateJob
    * [Error handling: Global: rescue_from several different Accounting::QB errors, set msg on task, re-raise; Per-loan: write error to task metadata but continue, raise general error after fininshing all loans]
    * Delete global issues only
    * Updater#qb_sync_for_loan_update
    * Updater#update_loan(l1)
        * Delete loan issues only
        * extract_qb_data(l1)
            * [Error handling: if line item extraction fails due to missing account, create problem transaction but continue]
        * InterestCalculator#recaculate(l1)
        * calculate_balances(l1)
    * Updater#update_loan(l2)
        * Delete loan issues only
        * extract_qb_data(l2)
        * InterestCalculator#recaculate(l2)
        * calculate_balances(l2)

## Error/Warning Handling

Errors and warnings are handled both globally (for fetch phases) and on a per-loan basis (for extract and write phases).

Errors and warnings are saved as SyncIssues and displayed to the user appropriately.

The data can be left in different states depending on where/how errors occur:

Full Fetch
  * Scope: Global
  * Resulting state: All data is deleted
  * Implications: Fine, starting over
Incremental Fetch
  * Scope: Global
  * Resulting state: Data may get rolled back if accessed via TransactionsController, or may be left in partially fetched state. last_updated_at is not updated in either case
  * Implications: Partially fetched should be ok b/c existing items should get noticed and re-used on next fetch
Extract
  * Scope: Per-loan
  * Resulting state: Fetch and extractions may get rolled back if accessed via TransactionsController, or may be left in partially extracted state.
  * Implications: Should be ok b/c extraction happens for all txns in loan every time (!)
Write
  * Scope: Per-loan
  * Resulting state: Fetch, extractions, and new txns may get rolled back if accessed via TransactionsController, or may be left in partially updated state. In either case, anything written to QBO will remain.
  * Implications: Should be ok b/c system should be idempotent and should re-use interest transactions on next run if they are correct.

### Error/Warning Catalog

* has_multiple_loans
  * Phases: Inc. Fetch, Full Fetch
  * Type: SyncIssue
  * Sync Issue Level: Error
  * Sync Issue Scope: Loan
  * Cause: Multiple line items with different classes in QBO journal entry
  * User Action To Correct: Fix data in Quickbooks so that txns only have one loan
* *_before_closed_books_date
  * Phases: Write
  * Type: SyncIssue
  * Sync Issue Level: Warning
  * Sync Issue Scope: Loan
  * Cause: Int Calculator starts with the earliest transaction on record. If Madeline would have added an int txn or repayment differently before the closed books date, we don't add it, but give a warning.
  * User Action To Correct: None
* Accounting::QB::UnprocessableAccountError
  * Phases: Extract
  * Type: Exception
  * Sync Issue Level: Error
  * Sync Issue Scope: Loan
  * Cause: Account is not in the list of fetched ones. Common case is if it's a deleted account.
  * User Action To Correct: Undelete account or change account in txn in QBO
* Accounting::QB::AccountsNotSelectedError
  * Phases: Inc. Fetch
  * Type: Exception
  * Sync Issue Level: Warning
  * Sync Issue Scope: Global
  * Cause: Accounts not selected
  * User Action To Correct: Select accounts
* Accounting::QB::DataResetRequiredError
  * Phases: Inc. Fetch
  * Type: Exception
  * Sync Issue Level: Warning
  * Sync Issue Scope: Global
  * Cause: Too long since fetched changes
  * User Action To Correct: Do a full fetch
* Accounting::QB::NotConnectedError
  * Phases: Inc. Fetch, Full Fetch
  * Type: Exception
  * Sync Issue Level: Warning
  * Sync Issue Scope: Global
  * Cause: No valid QB connection
  * User Action To Correct: Connect!
* Quickbooks::ServiceUnavailable
  * Phases: Inc. Fetch, Full Fetch
  * Type: Exception
  * Sync Issue Level: Warning
  * Sync Issue Scope: Global
  * Cause: QBO Down
  * User Action To Correct: Wait
* Quickbooks::ServiceUnavailable
  * Phases: Extract, Write
  * Type: Exception
  * Sync Issue Level: Error
  * Sync Issue Scope: Loan
  * Cause: QBO Down
  * User Action To Correct: Wait
* Unhandled error
  * Phases: Fetch
  * Type: Exception
  * Sync Issue Level: Warning
  * Sync Issue Scope: Global
  * Cause: Varies
  * User Action To Correct: Wait for admins to notice and take action
* Unhandled error
  * Phases: Extract, Write
  * Type: Exception
  * Sync Issue Level: Error
  * Sync Issue Scope: Loan
  * Cause: Varies
  * User Action To Correct: Wait for admins to notice and take action
