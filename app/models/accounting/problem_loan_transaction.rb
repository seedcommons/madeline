# == Schema Information
#
# Table name: accounting_problem_loan_transactions
#
#  accounting_transaction_id :bigint(8)
#  created_at                :datetime         not null
#  custom_data               :json
#  id                        :bigint(8)        not null, primary key
#  level                     :string
#  message                   :string           not null
#  project_id                :bigint(8)
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_accounting_problem_loan_transactions_on_project_id  (project_id)
#  index_plt_on_txn_id                                       (accounting_transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (accounting_transaction_id => accounting_transactions.id)
#  fk_rails_...  (project_id => projects.id)
#

module Accounting
  class ProblemLoanTransaction < ApplicationRecord
    belongs_to :loan, foreign_key: "project_id"
    belongs_to :accounting_transaction, class_name: "Accounting::Transaction"

    delegate :id, :display_name, to: :loan, prefix: :loan
    delegate :txn_date, :qb_id, :amount, :change_in_interest, :change_in_principal, :currency, :quickbooks_data, to: :accounting_transaction
    delegate :id, :description, to: :accounting_transaction, prefix: :txn

    def associated_loan_ids
      self.class.where(
        accounting_transaction_id: self.accounting_transaction_id
      ).map(&:project_id)
    end
  end
end
