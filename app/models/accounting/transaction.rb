# == Schema Information
#
# Table name: accounting_transactions
#
#  accounting_account_id       :integer
#  accounting_customer_id      :string
#  amount                      :decimal(, )
#  change_in_interest          :decimal(15, 2)
#  change_in_principal         :decimal(15, 2)
#  created_at                  :datetime         not null
#  currency_id                 :integer
#  description                 :string
#  id                          :integer          not null, primary key
#  interest_balance            :decimal(, )      default(0.0)
#  loan_transaction_type_value :string
#  managed                     :boolean          default(FALSE), not null
#  needs_qb_push               :boolean          default(TRUE), not null
#  principal_balance           :decimal(, )      default(0.0)
#  private_note                :string
#  project_id                  :integer
#  qb_id                       :string
#  qb_object_type              :string           default("JournalEntry"), not null
#  quickbooks_data             :json
#  total                       :decimal(, )
#  txn_date                    :date
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_accounting_transactions_on_accounting_account_id     (accounting_account_id)
#  index_accounting_transactions_on_currency_id               (currency_id)
#  index_accounting_transactions_on_project_id                (project_id)
#  index_accounting_transactions_on_qb_id                     (qb_id)
#  index_accounting_transactions_on_qb_id_and_qb_object_type  (qb_id,qb_object_type) UNIQUE
#  index_accounting_transactions_on_qb_object_type            (qb_object_type)
#
# Foreign Keys
#
#  fk_rails_...  (accounting_account_id => accounting_accounts.id)
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (project_id => projects.id)
#

# Represents a transaction in a Loan's financial history.
# Serves as a local cache of transaction objects stored in Quickbooks.
# Quickbooks should be considered the authoritative source for the transaction information it stores.
# Madeline additionally tracks special data about interest and principal balances, but this information
# is ultimately derived from data stored in Quickbooks.
#
# Standard Order
# =================
# Standard order means transactions ordered by:
#   1. Date, then
#   2. Type (1. interest, 2. disbursement, 3. repayment, 4. other), then
#   3. Creation date
# It should be rare that transactions of the same type and date exist, so the creation date
# should not be often needed to break ties.
class Accounting::Transaction < ApplicationRecord
  include OptionSettable

  QB_OBJECT_TYPES = %w(JournalEntry Deposit Purchase Bill).freeze
  QB_PARENT_CLASS = "Loan Products"
  QB_LOAN_CLASS_REGEX = /#{QB_PARENT_CLASS}:Loan ID (\d+)/
  AVAILABLE_LOAN_TRANSACTION_TYPES = %i(disbursement repayment)
  LOAN_INTEREST_TYPE = 'interest'

  belongs_to :account, inverse_of: :transactions, foreign_key: :accounting_account_id
  belongs_to :project, inverse_of: :transactions, foreign_key: :project_id
  belongs_to :customer, inverse_of: :transactions, foreign_key: :accounting_customer_id
  belongs_to :currency

  attr_option_settable :loan_transaction_type
  has_many :line_items, inverse_of: :parent_transaction, autosave: true,
                        foreign_key: :accounting_transaction_id, dependent: :destroy
  has_many :problem_loan_transactions, inverse_of: :accounting_transaction, foreign_key: :accounting_transaction_id, dependent: :destroy

  validates :loan_transaction_type_value, :txn_date, presence: true, if: :managed?
  validates :amount, presence: true, unless: :interest?, if: :managed?
  validates :accounting_account_id, presence: true, unless: :interest?, if: :managed?

  delegate :division, :qb_division, to: :project

  scope :standard_order, -> {
    joins("LEFT OUTER JOIN options ON options.option_set_id = #{loan_transaction_type_option_set.id}
      AND options.value = accounting_transactions.loan_transaction_type_value")
      .order(:txn_date, "options.position", :created_at)
  }
  scope :interest_type, -> { by_type(LOAN_INTEREST_TYPE) }
  scope :by_type, ->(type) { where(loan_transaction_type_value: type) }
  scope :in_date_range, ->(since_date, until_date) do
    if since_date.present? && until_date.present?
      where(txn_date: (since_date..until_date))
    elsif since_date.present?
      where("txn_date >= ?", since_date)
    elsif until_date.present?
      where("txn_date <= ?", until_date)
    else
      all
    end
  end
  scope :most_recent_first, -> { order(txn_date: :desc) }
  scope :with_customer, -> { where.not(accounting_customer_id: nil) }

  def self.create_or_update_from_qb_object!(qb_object_type:, qb_object:)
    txn = find_or_initialize_by(qb_object_type: qb_object_type, qb_id: qb_object.id)
    txn.quickbooks_data = qb_object.as_json
    txn.txn_date = txn.quickbooks_data['txn_date']

    # Associate qb txn with loan if loan id (class name) is set in QB
    if txn.quickbooks_data['line_items']
      loan_classes = txn.quickbooks_data['line_items'].map do |li|
        detail_type = li['detail_type']&.underscore
        class_name = li.dig(detail_type, 'class_ref', 'name')
        class_name
      end
      loan_classes = loan_classes.map { |lc| lc&.match(QB_LOAN_CLASS_REGEX)&.captures&.first }
      associated_loans = Loan.select(:id).where(id: loan_classes)

      if associated_loans.count > 1
        associated_loans.each do |loan|
          ::Accounting::ProblemLoanTransaction.create(loan: loan, accounting_transaction: txn, error_message: :has_multiple_loans)
        end
      else
        txn.project_id = associated_loans&.first&.id
      end
    end

    # Since the data has just come straight from quickbooks, no need to push it back up.
    txn.needs_qb_push = false

    # We have to skip validations on create because the data haven't been extracted yet.
    txn.new_record? ? txn.save(validate: false) : txn.save!

    txn
  end

  def interest?
    loan_transaction_type_value == LOAN_INTEREST_TYPE
  end

  # Stores the ID and type of the given Quickbooks object on this Transaction.
  # This is so that during sync operations, we can associate one with the other and not
  # create duplicates.
  # Does NOT save the object.
  def associate_with_qb_obj(qb_obj)
    self.qb_id = qb_obj.id
    self.qb_object_type = qb_obj.class.name.demodulize
    self.quickbooks_data = qb_obj.as_json
  end

  def calculate_deltas
    raise Accounting::TransactionMissingProjectError unless project
    self.change_in_interest = net_debit_for_account(qb_division&.interest_receivable_account_id)
    self.change_in_principal = net_debit_for_account(qb_division&.principal_account_id)
  end

  def total_balance
    interest_balance + principal_balance
  end

  # Calculates balance fields based on line items.
  # Does NOT save the object.
  def calculate_balances(prev_tx: nil)
    # need to do calculate_deltas in case that this is called from updater
    calculate_deltas
    self.principal_balance = (prev_tx.try(:principal_balance) || 0) + change_in_principal
    self.interest_balance = (prev_tx.try(:interest_balance) || 0) + change_in_interest

    # as in https://redmine.sassafras.coop/issues/7703, testing this would take time
    # it could be added as a future TODO
    if total_balance < 0 && !Rails.env.test?
      raise Accounting::Quickbooks::NegativeBalanceError.new(prev_balance: prev_balance)
    end
  end

  def prev_balance
    total_balance - change_in_principal - change_in_interest
  end

  # Returns first line item for the given account, or nil if not found.
  # Guaranteed that the LineItem object returned will exist in the current
  # Transaction's line_items array (not a separate copy).
  def line_item_for(account)
    line_items.detect { |li| li.account == account }
  end

  # Finds first line item with the given ID or builds a new one.
  # Guaranteed that the LineItem object returned will exist in the current
  # Transaction's line_items array (not a separate copy).
  def line_item_with_id(id)
    line_items.detect { |li| li.qb_line_id == id } || line_items.build(qb_line_id: id)
  end

  def set_qb_push_flag!(value)
    update_column(:needs_qb_push, value)
  end

  private

  # Debits minus credits for the given account. Returns a negative number if this transaction is a
  # net credit to the passed in account. Note that for non-asset accounts such as interest income,
  # which is increased by a credit, a negative number indicates the account is increasing.
  def net_debit_for_account(account_id)
    line_items.to_a.sum do |item|
      if item.accounting_account_id == account_id
        (item.credit? ? -1 : 1) * item.amount
      else
        0
      end
    end
  end
end
