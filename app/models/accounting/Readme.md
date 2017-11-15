# Madeline Accounting Features

Madeline includes support for managing loan financial data with Quickbooks Online.

Detailed documentation of this functionality is found throughout the classes in the Accounting namespace.

General Notes:

* Quickbooks Online is considered the authoritative source for accounting data.
* Madeline's roles include:
    * Allowing easy viewing and editing of transaction data for a given Loan. In Quickbooks, the data is not easily viewable by loan.
    * Computing interest and principal amounts according to Madeline's non-extractive interest formula.
    * Recomputing and updating these amounts when transaction data changes.
