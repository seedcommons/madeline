# Madeline Accounting Features
## Accounting README

### About
Madeline includes support for managing loan financial data with QuickBooks Online.

Detailed documentation of this functionality is found throughout the classes in the Accounting namespace. See the `app/models/accounting` folder.

### General Notes

* [QuickBooks Online](https://developer.intuit.com/docs/00_quickbooks_online/1_get_started/00_get_started) is considered the authoritative source for accounting data.
* Madeline's roles include:
    * Allowing easy viewing and editing of transaction data for a given Loan. In QuickBooks, the data is not easily viewable by loan.
    * Allowing easy creation of various types of standard transactions.
    * Computing interest and principal amounts for repayments according to Madeline's non-extractive interest formula.
    * Computing running interest and principal balances for a loan.
    * Recomputing and updating these amounts when transaction data changes from either Madeline or QuickBooks.

### Change Tracking

Changes to transactions in Madeline need to get pushed back to QuickBooks. There are currently several
ways for transactions to get created/updated on the Madeline side:

1. Creation via UI
2. Auto-creation of an interest transaction upon creation of a disbursement or repayment when there are transactions on previous days but no interest transaction on
3. Modification via the interest calculation process

Any code that changes a transaction is responsible for setting the `needs_qb_push` flag on that transaction.
The TransactionReconciler then obeys this flag when considering whether to push a transaction to QuickBooks.

The flag defaults to `true`, and therefore if a transaction is getting created that doesn't
need pushing to QB (e.g. one that was just downloaded) the flag should be overridden.
