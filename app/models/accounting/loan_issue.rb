module Accounting
  class LoanIssue < ApplicationRecord
    belongs_to :loan, foreign_key: "project_id"
    belongs_to :accounting_transaction, class_name: "Accounting::Transaction"

    # Issues with no project_id apply to all Loans
    scope :for_loan_or_global, ->(l) { for_loan(l).or(no_loan) }
    scope :for_loan, ->(l) { where(loan: l) }
    scope :no_loan, -> { where(loan: nil) }
    scope :error, -> { where(level: "error") }
    scope :warning, -> { where(level: "warning") }

    delegate :id, :display_name, to: :loan, prefix: :loan
    delegate :txn_date, :qb_id, :amount, :change_in_interest, :change_in_principal, :currency, :quickbooks_data, to: :accounting_transaction, allow_nil: true
    delegate :id, :description, to: :accounting_transaction, prefix: :txn, allow_nil: true
    delegate :division, to: :loan

    def txn?
      accounting_transaction.present?
    end

    def loan?
      loan.present?
    end

    def associated_loan_ids
      self.class.where(
        accounting_transaction_id: self.accounting_transaction_id
      ).map(&:project_id).compact
    end
  end
end
