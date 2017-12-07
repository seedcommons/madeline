# Madeline Accounting Features

Madeline includes support for managing loan financial data with Quickbooks Online.

Detailed documentation of this functionality is found throughout the classes in the Accounting namespace.

### General Notes

* Quickbooks Online is considered the authoritative source for accounting data.
* Madeline's roles include:
    * Allowing easy viewing and editing of transaction data for a given Loan. In Quickbooks, the data is not easily viewable by loan.
    * Computing interest and principal amounts according to Madeline's non-extractive interest formula.
    * Recomputing and updating these amounts when transaction data changes.

### Change Tracking

Changes to transactions in Madeline need to get pushed back to Quickbooks. There are currently several
ways for transactions to get created/updated on the Madeline side:

1. Creation via UI
2. Auto-creation of interest transaction upon creation other type of transaction
3. Modification via the interest calculation process

Any code that changes a transaction is responsible for setting the `needs_qb_push` flag on that transaction.
The TransactionReconciler then obeys this flag when considering whether to push a transaction to Quickbooks.

The flag defaults to `true`, and therefore if a transaction is getting created that doesn't
need pushing to QB (e.g. one that was just downloaded) the flag should be overridden.
