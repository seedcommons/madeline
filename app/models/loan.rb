# Note: loan duplication happens under project duplication

class Loan < Project
  include MediaAttachable

  STATUS_ACTIVE_VALUE = 'active'
  STATUS_COMPLETED_VALUE = 'completed'
  TXN_MODES = %i(automatic read_only).freeze
  TXN_MODE_AUTO = 'automatic'
  TXN_MODE_READ_ONLY = 'read_only'
  SOURCE_OF_CAPITAL_OPTIONS = %w(shared allocated proprietary).freeze
  # adding these because if someone clicks 'All' on the loans public page
  # the url divisions are set as strings not symbols
  # These are the ones we're certain of at the moment
  URL_DIVISIONS = %w(us nicaragua).freeze


  belongs_to :organization
  belongs_to :currency
  has_one :health_check, class_name: "LoanHealthCheck", foreign_key: :loan_id, dependent: :destroy
  has_many :response_sets, dependent: :destroy

  scope :status, ->(status) { where(status_value: status) }
  scope :active, -> { status("active") }
  scope :completed, -> { status("completed") }
  scope :active_or_completed, -> { where(status_value: %w(active completed)) }
  scope :related_loans, ->(loan) { loan.organization.loans.where.not(id: loan.id) }
  scope :changed_since, ->(date) { where("updated_at > :date", date: date) }

  delegate :name, :country, :street_address, :city, :state, :postal_code, :entity_structure, :naics_code, :census_tract_code, :date_established, to: :organization, prefix: :coop
  delegate :name, :membership_status, to: :division, prefix: true
  delegate :closed_books_date, to: :division
  delegate :qb_department, to: :division
  delegate :top_level_division, to: :division

  # Beware, the methods generated by this include will fail
  # without the corresponding OptionSet records existing in the database.
  attr_option_settable :status, :loan_type, :public_level

  validates :organization, :public_level_value, presence: true
  validates :source_of_capital, :inclusion => {:in => SOURCE_OF_CAPITAL_OPTIONS}

  before_create :build_health_check

  # other models use after_commit for recalculate_loan_health step
  # after_save lets us positively identify changes to date fields that
  # affect loan health. In Rails 5, the touch method used in txn model
  # has all fields appear in prev changes in after_commit and there is
  # no way to distinguish between `touch` vs changes to date fields
  # This can probably be cleaned up in Rails 6 - see https://github.com/rails/rails/issues/30466
  after_save :recalculate_loan_health

  def self.default_filter
    {status: 'active', country: 'all'}
  end

  def self.txn_mode_choices
    TXN_MODES
  end

  # Rate is entered as a percent
  def interest_rate
    rate / 100 if rate
  end

  def recalculate_loan_health
    # if at least one date field (besides updated_at) changed
    if previous_changes.keys.select { |k| k.match("_date") }.count > 0
      RecalculateLoanHealthJob.perform_later(loan_id: id)
    end
  end

  def default_name
    return if organization.blank?
    date = signing_date || created_at.to_date

    # date will always return a value so there is no need to use ldate
    "#{organization.name} - #{I18n.l(date)}"
  end

  def status
    status_label
  end

  def loan_type
    loan_type_label
  end

  def country
    # TODO: Temporary fix sets country to US when not found
    # @country ||= Country.where(name: self.division.super_division.country).first || Country.where(name: 'United States').first
    # todo: beware code that expected a country to always exist can break if US country not included in seed.data
    @country ||= organization.try(:country) || Country.where(iso_code: 'US').first
  end

  def display_currency
    currency ? currency.try(:name) : ''
  end

  def images
    media.where(kind_value: "image")
  end

  def location
    if self.organization.try(:city).present?
      self.organization.city + ', ' + self.country.name
    else self.country.name end
  end

  def signing_date_long
    # this may or may not be available so setting a default value
    I18n.l(self.signing_date, format: :long, default: '')
  end

  def coop_media(limit: 100, images_only: false)
    organization.get_media(limit: limit, images_only: images_only)
  end

  def loan_media(limit: 100, images_only: false)
    self.get_media(limit: limit, images_only: images_only)
  end

  def log_media(limit: 100, images_only: false)
    media = []
    self.project_logs.find_each do |log|
      media += log.get_media(limit: limit - media.count, images_only: images_only)
      return media unless limit > media.count
    end
    media
  end

  def featured_pictures(limit: 1)
    pics = []
    coop_pics = coop_media(limit: limit, images_only: true).to_a
    # use first coop picture first
    pics << coop_pics.shift if coop_pics.count > 0
    return pics unless limit > pics.count
    # then loan pics
    pics += loan_media(limit: limit - pics.count, images_only: true)
    return pics unless limit > pics.count
    # then log pics
    pics += log_media(limit: limit - pics.count, images_only: true)
    return pics unless limit > pics.count
    # then remaining coop pics
    pics += coop_pics[0, limit - pics.count]
    return pics
  end

  def thumb_path
    if !self.featured_pictures.empty?
      self.featured_pictures.first.item.thumb.url
    else "/images/seedcommons.jpg" end
  end

  def ensure_currency
    currency || Currency.find_by(code: 'USD')
  end

  def active?
    status_value == STATUS_ACTIVE_VALUE
  end

  def healthy?
    return false unless health_check
    health_check.healthy?
  end

  def health_status_available?
    return !health_check.nil?
  end

  def sum_of_disbursements(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    transactions.by_type("disbursement").in_date_range(start_date, end_date).map { |t| t.amount }.sum
  end

  def sum_of_repayments(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    transactions.by_type("repayment").in_date_range(start_date, end_date).map { |t| t.amount }.sum
  end

  def repayments_of_interest(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    transactions.by_type("repayment").in_date_range(start_date, end_date).map { |t| t.change_in_interest }.sum
  end

  def repayments_of_principal(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    transactions.by_type("repayment").in_date_range(start_date, end_date).map { |t| t.change_in_principal }.sum
  end

  def total_accrued_interest(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    transactions.by_type("interest").in_date_range(start_date, end_date).map { |t| t.change_in_interest }.sum
  end

  def change_in_interest(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    changes = transactions.in_date_range(start_date, end_date).map { |t| (t.change_in_interest) }
    raise Accounting::TransactionDataMissingError if changes.any?(&:blank?)
    changes.sum
  end

  def change_in_principal(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    changes = transactions.in_date_range(start_date, end_date).map { |t| (t.change_in_principal) }
    raise Accounting::TransactionDataMissingError if changes.any?(&:blank?)
    changes.sum
  end

  def final_principal_balance(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    transactions.standard_order.in_date_range(start_date, end_date).last.principal_balance
  end

  def final_interest_balance(start_date: nil, end_date: nil)
    return nil if transactions.standard_order.in_date_range(start_date, end_date).empty?
    transactions.standard_order.in_date_range(start_date, end_date).last.interest_balance
  end

  def default_accounting_customer_for_transaction(transaction)
    reference_transaction = transactions.by_type(transaction.loan_transaction_type_value).with_customer.most_recent_first.first
    reference_transaction ||= transactions.by_type([:repayment, :disbursement]).with_customer.most_recent_first.first
    customer = reference_transaction.customer if reference_transaction.present?
    customer || Accounting::Customer.find_by(name: organization.name)
  end

  def no_interest_rate?
    interest_rate.nil? || interest_rate.zero?
  end

  def txns_read_only?
    txn_handling_mode == TXN_MODE_READ_ONLY
  end

  def num_sync_issues_by_level(level)
    return nil if transactions.empty?
    Accounting::SyncIssue.where(project_id: id, level: level).size
  end


    #start_date is the data export's start date; end_date is the data export's end_date
   def calculate_date_ranges
     date_ranges = []
     next_start_date = loan.transactions
     next_end_date = start_date.end_of_year
     while next_end_date < end_date.beginning_of_year
       date_ranges << [next_start_date, next_end_date]
       next_end_date = next_end_date + 1.year
       next_start_date = next_end_date.beginning_of_year
     end
     date_ranges << [end_date.beginning_of_year, end_date]
   end

  # for use in statements, returns tuples of statement start & end dates
  def annual_statement_ranges
    date_ranges = []
    start_date = transactions.pluck(:txn_date).sort.first
    end_date = Date.today
    next_start_date = start_date
    next_end_date = start_date.end_of_year
    while next_end_date < end_date
      date_ranges << [next_start_date, next_end_date]
      next_end_date = next_end_date + 1.year
      next_start_date = next_end_date.beginning_of_year
    end
    date_ranges << [end_date.beginning_of_year, end_date]
  end

  # for use in statements, returns tuples of statement start & end dates
  def quarterly_statement_ranges
    date_ranges = []
    start_date = Date.today.last_year.beginning_of_year
    end_date = Date.today
    next_start_date = start_date
    next_end_date = start_date.end_of_quarter
    while next_end_date < end_date
      date_ranges << [next_start_date, next_end_date]
      next_start_date = next_end_date.end_of_quarter + 1.day
      next_end_date = next_start_date.end_of_quarter
    end
    date_ranges << [end_date.beginning_of_year, end_date]
  end
end
