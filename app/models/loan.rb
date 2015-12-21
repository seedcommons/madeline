class Loan < ActiveRecord::Base
  include TranslationModule, MediaModule

  belongs_to :cooperative, :foreign_key => 'CooperativeID'
  belongs_to :division, :foreign_key => 'SourceDivision'
  has_many :repayments, :foreign_key => 'LoanID'

  scope :country, ->(country) {
    joins(division: :super_division).where('super_divisions_Divisions.Country' => country) unless country == 'all'
  }
  scope :status, ->(status) {
    where(:Nivel => case status
      when 'active' then 'Prestamo Activo'
      when 'completed' then 'Prestamo Completo'
      when 'all' then ['Prestamo Activo','Prestamo Completo']
    end)
  }

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

  def name
    if self.cooperative then I18n.t :project_with, name: self.cooperative.Name
    else I18n.t :project_id, id: self.ID.to_s end
  end

  def country
    # TODO: Temporary fix sets country to US when not found
    @country ||= Country.where(name: self.division.super_division.country).first || Country.where(name: 'United States').first
  end

  def currency
    @currency ||= self.country.default_currency
  end

  def location
    if self.cooperative.try(:city).present?
      self.cooperative.city + ', ' + self.country.name
    else self.country.name end
  end

  def signing_date_long
    I18n.l self.signing_date, format: :long if self.signing_date
  end

  def status
    case self.nivel
      when 'Prestamo Activo' then I18n.t :loan_active
      when 'Prestamo Completo' then I18n.t :loan_completed
    end
  end

  def short_description
    self.translation('ShortDescription')
  end
  def description
    self.translation('Description')
  end

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
