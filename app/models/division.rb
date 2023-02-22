class Division < ApplicationRecord
  include DivisionBased

  MEMBERSHIP_STATUS_OPTIONS = %w(ally apprentice lending full).freeze

  has_closure_tree dependent: :restrict_with_exception, order: :name
  resourcify
  alias_attribute :super_division, :parent

  normalize_attributes :logo_text, :banner_fg_color, :banner_bg_color, :accent_main_color, :accent_fg_color

  has_many :loans, dependent: :restrict_with_exception
  has_many :people, dependent: :restrict_with_exception
  has_many :organizations, dependent: :restrict_with_exception

  has_many :question_sets, inverse_of: :division, dependent: :restrict_with_exception
  has_many :questions
  has_many :option_sets, dependent: :destroy

  # Bug in closure_tree requires these 2 lines (https://github.com/mceachen/closure_tree/issues/137)
  has_many :self_and_descendants, through: :descendant_hierarchies, source: :descendant
  has_many :self_and_ancestors, through: :ancestor_hierarchies, source: :ancestor

  has_one :qb_connection, class_name: "Accounting::QB::Connection", dependent: :destroy, inverse_of: :division
  has_one :qb_department, class_name: "Accounting::QB::Department", dependent: :nullify, inverse_of: :division
  accepts_nested_attributes_for :qb_department

  belongs_to :principal_account, class_name: "Accounting::Account"
  belongs_to :interest_receivable_account, class_name: "Accounting::Account"
  belongs_to :interest_income_account, class_name: "Accounting::Account"

  belongs_to :parent, class_name: "Division"

  # Note the requirements around a single currency or a 'default currency' per division has been in
  # flux. Should probably rename the DB column to 'default_currency_id' once definitively settled.
  belongs_to :default_currency, class_name: "Currency", foreign_key: "currency_id"
  alias_attribute :default_currency_id, :currency_id

  belongs_to :organization # the organization which represents this loan agent division

  mount_uploader :logo, LogoUploader

  validate :parent_division_and_name
  validates :name, presence: true
  validates :parent, presence: true, if: -> { Division.root.present? && Division.root_id != id }
  validates :short_name, presence: true, uniqueness: true, if: -> { self.public }

  before_validation :generate_short_name

  scope :by_name, -> { order(Arel.sql("LOWER(divisions.name)")) }
  scope :published, -> { where(public: true) }

  delegate :connected?, to: :qb_connection, prefix: :quickbooks, allow_nil: true
  delegate :company_name, to: :qb_connection, prefix: :quickbooks, allow_nil: true

  attr_accessor :qb_department_id # allows this field in simple_form

  def self.root_id
    result = root.try(:id)
    result
  end

  def self.in_division(division)
    division ? division.self_and_descendants : all
  end

  def self.qb_divisions
    Accounting::QB::Connection.all.map(&:division)
  end

  def self.qb_accessible_divisions
    qb_divisions.map(&:self_and_descendants).flatten.uniq
  end

  # interface compatibility with other models
  def division
    self
  end

  # Allows efficient multiple tree comparisons by caching.
  def self_or_ancestor_of?(other_division)
    @self_and_descendants_hash ||= self_and_descendants.pluck(:id).index_by(&:itself)
    @self_and_descendants_hash.key?(other_division.id)
  end

  # Allows efficient multiple tree comparisons by caching.
  def self_or_descendant_of?(other_division)
    @self_and_ancestors_hash ||= self_and_ancestors.pluck(:id).index_by(&:itself)
    @self_and_ancestors_hash.key?(other_division.id)
  end

  # returns the oldest ancestor before root for the division (can be oneself)
  # returns nil for root division
  # pls use this method sparingly per page load, or memoize
  def top_level_division
    top_level_name = self.ancestry_path.try(:[], 1)
    return Division.find_by(name: top_level_name) if top_level_name.present?
  end

  def has_logo_text?
    logo_text.present?
  end

  def has_noncascading_dependents?
    Division.where(parent: self).present? ||
      Organization.where(division: self).present? ||
      Loan.where(division: self).present? ||
      Person.where(division: self).present?
  end

  def users
    people.with_system_access
  end

  def locales
    return [] if self[:locales].blank?

    self[:locales].sort.select(&:present?).map(&:to_sym)
  end

  def locale_names
    locales.map do |locale|
      I18n.t("locale_name.#{locale}", locale: locale)
    end
  end

  def accounts
    @accounts ||= [principal_account, interest_receivable_account, interest_income_account].compact
  end

  def qb_accounts_selected?
    accounts.size == 3
  end

  # If no valid QB connection on this division, fall back to nearest ancestor with QB connection.
  # May return nil.
  def qb_division
    # Division.root
    qb_connection&.connected? ? self : parent&.qb_division
  end

  def qb_department?
    qb_department.present?
  end

  def parent_division_and_name
    errors.add(:name, :same_as_parent) if parent&.name == name
  end

  def generate_short_name
    # no change to short_name that is already saved and therefore uniq
    return if self.short_name.present? && self.short_name == self.attribute_in_database(:short_name)

    # accept a short_name that is being provided and is uniq
    return if self.short_name.present? && Division.pluck(:short_name).exclude?(self.short_name)

    # short_name not provided or provided short_name is not uniq
    self.short_name ||= name.parameterize
    self.short_name = "#{self.short_name}-#{SecureRandom.uuid}" if Division.pluck(:short_name).include?(self.short_name)
  end

  # there is only one closed books date system wide
  # it is managed in Accounting Settings and belongs to root division
  def shared_closed_books_date
    root.closed_books_date
  end
end
