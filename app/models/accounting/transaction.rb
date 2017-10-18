# == Schema Information
#
# Table name: accounting_transactions
#
#  accounting_account_id       :integer
#  amount                      :decimal(, )
#  created_at                  :datetime         not null
#  currency_id                 :integer
#  description                 :string
#  id                          :integer          not null, primary key
#  interest_balance            :decimal(, )      default(0.0)
#  loan_transaction_type_value :string
#  principal_balance           :decimal(, )      default(0.0)
#  private_note                :string
#  project_id                  :integer
#  qb_id                       :string
#  qb_transaction_type         :string           not null
#  quickbooks_data             :json
#  total                       :decimal(, )
#  txn_date                    :date
#  updated_at                  :datetime         not null
#
# Indexes
#
#  acc_trans_qbid_qbtype__unq_idx                          (qb_id,qb_transaction_type) UNIQUE
#  index_accounting_transactions_on_accounting_account_id  (accounting_account_id)
#  index_accounting_transactions_on_currency_id            (currency_id)
#  index_accounting_transactions_on_project_id             (project_id)
#  index_accounting_transactions_on_qb_id                  (qb_id)
#  index_accounting_transactions_on_qb_transaction_type    (qb_transaction_type)
#
# Foreign Keys
#
#  fk_rails_3b7e4ae807  (accounting_account_id => accounting_accounts.id)
#  fk_rails_662fd2ba2d  (project_id => projects.id)
#  fk_rails_db49322130  (currency_id => currencies.id)
#

class Accounting::Transaction < ActiveRecord::Base
  include OptionSettable

  QB_TRANSACTION_TYPES = %w(JournalEntry Deposit Purchase).freeze
  AVAILABLE_LOAN_TRANSACTION_TYPES = %i(disbursement repayment)
  LOAN_INTEREST_TYPE = 'interest'

  belongs_to :account, inverse_of: :transactions, foreign_key: :accounting_account_id
  belongs_to :project, inverse_of: :transactions, foreign_key: :project_id
  belongs_to :currency

  attr_option_settable :loan_transaction_type
  has_many :line_items, inverse_of: :parent_transaction,
    foreign_key: :accounting_transaction_id, dependent: :destroy

  before_save :update_fields_from_quickbooks_data

  validates :loan_transaction_type_value, :txn_date, :accounting_account_id, presence: true
  validates :amount, presence: true, unless: :uninitialized_interest?

  delegate :division, to: :project

  scope :standard_order, -> {
    joins("LEFT OUTER JOIN options ON options.option_set_id = #{loan_transaction_type_option_set.id}
      AND options.value = accounting_transactions.loan_transaction_type_value").
    order(:txn_date, "options.position", :created_at)
  }

  def self.create_or_update_from_qb_object(transaction_type:, qb_object:)
    transaction = find_or_initialize_by qb_transaction_type: transaction_type, qb_id: qb_object.id
    transaction.quickbooks_data = qb_object.as_json
    transaction.save!(validate: false)
  end

  def uninitialized_interest?
    return false unless qb_transaction_type == LOAN_INTEREST_TYPE
    qb_id.blank?
  end

  def quickbooks_data
    read_attribute(:quickbooks_data).try(:with_indifferent_access)
  end

  # Stores the ID and type of the given Quickbooks object on this Transaction.
  # This is so that during sync operations, we can associate one with the other and not
  # create duplicates.
  # Does NOT save the object.
  def associate_with_qb_obj(qb_obj)
    self.qb_id = qb_obj.id
    self.qb_transaction_type = qb_obj.class.name.demodulize
  end

  def change_in_principal
    @change_in_principal ||= sum_for_account(division.principal_account_id)
  end

  def change_in_interest
    @change_in_interest ||= sum_for_account(division.interest_receivable_account_id)
  end

  def total_balance
    interest_balance + principal_balance
  end

  def calculate_balances(prev_tx: nil)
    self.principal_balance = (prev_tx.try(:principal_balance) || 0) + change_in_principal
    self.interest_balance = (prev_tx.try(:interest_balance) || 0) + change_in_interest
  end

  # Returns first line item for the given account, or nil if not found.
  def line_item_for(account)
    line_items.detect { |li| li.account == account }
  end

  private

  def sum_for_account(account_id)
    line_items.to_a.sum do |item|
      if item.accounting_account_id == account_id
        (item.credit? ? -1 : 1) * item.amount
      else
        0
      end
    end
  end

  def update_fields_from_quickbooks_data
    return unless quickbooks_data.present?

    self.amount = first_quickbooks_line_item[:amount]
    self.description = first_quickbooks_line_item[:description]
    self.project_id = first_quickbooks_class_name
    self.txn_date = quickbooks_data[:txn_date]
    self.private_note = quickbooks_data[:private_note]
    self.total = quickbooks_data[:total]
    self.currency_id = lookup_currency_id
  end

  def first_quickbooks_line_item
    return {} unless quickbooks_data[:line_items]
    quickbooks_data[:line_items].first
  end

  def first_quickbooks_class_name
    first_quickbooks_line_item[:journal_entry_line_detail].try(:[], :class_ref).try(:[], :name)
  end

  def lookup_currency_id
    if quickbooks_data && quickbooks_data[:currency_ref]
      Currency.find_by(code: quickbooks_data[:currency_ref][:value]).try(:id)
    elsif project
      project.currency_id
    end
  end
end
