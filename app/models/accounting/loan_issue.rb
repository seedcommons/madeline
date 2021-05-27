module Accounting
  class ProblemLoanTransaction < ApplicationRecord
    belongs_to :loan, foreign_key: "project_id"
    belongs_to :accounting_transaction, class_name: "Accounting::Transaction"

    delegate :id, :display_name, to: :loan, prefix: :loan
    delegate :txn_date, :qb_id, :amount, :change_in_interest, :change_in_principal, :currency, :quickbooks_data, to: :accounting_transaction
    delegate :id, :description, to: :accounting_transaction, prefix: :txn
    delegate :division, to: :loan

    def associated_loan_ids
      self.class.where(
        accounting_transaction_id: self.accounting_transaction_id
      ).map(&:project_id)
    end
  end
end
