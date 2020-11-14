# == Schema Information
#
# Table name: accounting_problem_loan_transactions
#
#  id                        :bigint           not null, primary key
#  custom_data               :json
#  level                     :string
#  message                   :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  accounting_transaction_id :bigint
#  project_id                :bigint
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
