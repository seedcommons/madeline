class Loan < ActiveRecord::Base
  include Translatable, MediaAttachable

  belongs_to :division
  belongs_to :organization
  belongs_to :primary_agent, class_name: 'Person'
  belongs_to :secondary_agent, class_name: 'Person'
  belongs_to :currency
  belongs_to :representative, class_name: 'Person'
  belongs_to :organization_snapshot

  ##JE todo: for next integration pass
  # has_many :project_steps, as: :project


  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details


  validates :division_id, presence: true


  # todo: proper handling needs to be defined, probably a pre-populated and editable display name
  def name
    "Project with #{organization.try(:name)}"
  end

  def status
    STATUS_OPTIONS.label_for(status_option_id)
  end

  def loan_type
    LOAN_TYPE_OPTIONS.label_for(loan_type_option_id)
  end

  # the special name of a default step to use/create when migrating a log without a step
  DEFAULT_STEP_NAME = '[default]'

  # creates / reuses a default step when migrating ProjectLogs without a proper owning step
  # beware, not at all optimized, but sufficient for migration.
  # not sure if this will be useful beyond migration.  if so, perhaps worth better optimizing,
  # if not, can remove once we're past the production migration process
  def default_step
    step = project_steps.select{|s| s.summary == DEFAULT_STEP_NAME}.first
    unless step
      # Could perhaps optimize this with a 'find_or_create_by', but would be tricky with the translatable 'summary' field,
      # and it's nice to be able to log the operation.
      logger.info {"default step not found for loan[#{id}] - creating"}
      step = project_steps.create
      step.update({summary: DEFAULT_STEP_NAME})
    end
    step
  end


  def self.status_active_id
    STATUS_ACTIVE_ID
  end

  STATUS_ACTIVE_ID = 1

  # place holder display name mappings until final solution decided upon
  STATUS_OPTIONS = OptionSet.new(
      [ [STATUS_ACTIVE_ID, 'Active'],
        [2, 'Completed'],
        [3, 'Frozen'],
        [4, 'Liquidated'],
        [5, 'Prospective'],
        [6, 'Refinanced'],
        [7, 'Relationship'],
        [8, 'Relationship Active']
      ])

  # used for resolving id from legacy data
  MIGRATION_STATUS_OPTIONS = OptionSet.new(
      [ [STATUS_ACTIVE_ID, 'Prestamo Activo'],
        [2, 'Prestamo Completo'],
        [3, 'Prestamo Congelado'],
        [4, 'Prestamo Liquidado'],
        [5, 'Prestamo Prospectivo'],
        [6, 'Prestamo Refinanciado'],
        [7, 'Relacion'],
        [8, 'Relacion Activo']
      ])

  LOAN_TYPE_OPTIONS = OptionSet.new(
      [ [1, "Liquidity line of credit"],
        [2, "Investment line of credit"],
        [3, "Investment Loans"],
        [4, "Evolving loan"],
        [5, "Single Liquidity line of credit"],
        [6, "Working Capital Investment Loan"],
        [7, "Secured Asset Investment Loan"]
      ])

  PROJECT_TYPE_OPTIONS = OptionSet.new(
      [ [1, 'Conversion'],
        [2, 'Expansion'],
        [3, 'Start-up'],
      ])

  PUBLIC_LEVEL_OPTIONS = OptionSet.new(
      [ [1, 'Featured'],
        [2, 'Hidden'],
      ])


  ##
  ## todo: further review and cleanup of legacy code
  ##

  scope :country, ->(country) {
    joins(division: :super_division).where('super_divisions_Divisions.Country' => country) unless country == 'all'
  }
  scope :status, ->(status) { where(status: status) }
  scope :visible, -> { where.not(publicity_status: 'hidden') }

  def self.default_filter
    {
      status: 'active',
      country: 'all',
    }
  end

  def self.filter_by_params(params)
    params.reverse_merge! self.default_filter
    params[:country] = 'Argentina' if params[:division] == :argentina
    scoped = self.all
    scoped = scoped.country(params[:country]) if params[:country]
    scoped = scoped.status(params[:status]) if params[:status]
    scoped
  end

  def country
    # TODO: Temporary fix sets country to US when not found
    # @country ||= Country.where(name: self.division.super_division.country).first || Country.where(name: 'United States').first
    @country ||= organization.try(:country) || Country.where(iso_code: 'US').first
  end

  def currency
    @currency ||= self.country.default_currency
  end

  def location
    if self.organization.try(:city).present?
      self.organization.city + ', ' + self.country.name
    else self.country.name end
  end

  def signing_date_long
    I18n.l self.signing_date, format: :long if self.signing_date
  end

  # def short_description
  #   self.translation('ShortDescription')
  # end
  # def description
  #   self.translation('Description')
  # end

  def coop_media(limit=100, images_only=false)
    get_media('Cooperatives', self.cooperative.try(:id), limit, images_only)
  end

  def loan_media(limit=100, images_only=false)
    get_media('Loans', self.id, limit, images_only)
  end

  def log_media(limit=100, images_only=false)
    media = []
    begin
      self.logs("Date").each do |log|
        media += log.media(limit - media.count, images_only)
        return media unless limit > media.count
      end
    rescue Mysql2::Error # some logs have invalid dates
    end
    return media
  end

  def featured_pictures(limit=1)
    pics = []
    coop_pics = get_media('Cooperatives', self.cooperative.try(:id), limit, images_only=true).to_a
    # use first coop picture first
    pics << coop_pics.shift if coop_pics.count > 0
    return pics unless limit > pics.count
    # then loan pics
    pics += get_media('Loans', self.id, limit - pics.count, images_only=true)
    return pics unless limit > pics.count
    # then log pics
    pics += self.log_media(limit - pics.count, images_only=true)
    return pics unless limit > pics.count
    # then remaining coop pics
    pics += coop_pics[0, limit - pics.count]
    return pics
  end

  def thumb_path
    if !self.featured_pictures.empty?
      self.featured_pictures.first.paths[:thumb]
    else "/assets/ww-avatar-watermark.png" end
  end

  def amount_formatted
    currency_format(self.amount, self.currency)
  end

  def project_events(order_by="Completed IS NULL OR Completed = '0000-00-00', Completed, Date")
    @project_events ||= ProjectEvent.includes(project_logs: :progress_metric).
      where("lower(ProjectTable) = 'loans' and ProjectID = ?", self.ID).order(order_by)
    @project_events.reject do |p|
      # Hide past uncompleted project events without logs (for now)
      !p.completed && p.project_logs.empty? && p.date <= Date.today
    end
  end

  def logs(order_by="Date DESC")
    @logs ||= ProjectLog.where("lower(ProjectTable) = 'loans' and ProjectID = ?", self.ID).order(order_by)
  end
end
