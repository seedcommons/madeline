# Populates the option set table with basic values. Called by seeds.rb.
class OptionSetCreator
  def self.create_all
    new.create_all
  end

  def create_all
    create_loan_status
    create_basic_project_status
    create_loan_type
    create_public_level
    create_step_type
    create_progress_metric
    create_media_kind
    create_loan_transaction_type
    create_organization_inception
  end

  def create_loan_status
    loan_status = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'status')

    active = loan_status.options.find_or_create_by(value: 'active')
    active.label_translations = {
        en: I18n.t('database.option_sets.loan_status.active', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.active', locale: 'es')
      }
    active.save

    completed = loan_status.options.find_or_create_by(value: 'completed')
    completed.label_translations = {
      en: I18n.t('database.option_sets.loan_status.completed', locale: 'en'),
      es: I18n.t('database.option_sets.loan_status.completed', locale: 'es')
    }
    completed.save

    frozen = loan_status.options.find_or_create_by(value: 'frozen')
    frozen.label_translations = {
      en: I18n.t('database.option_sets.loan_status.frozen', locale: 'en'),
      es: I18n.t('database.option_sets.loan_status.frozen', locale: 'es')
    }
    frozen.save

    liquidated = loan_status.options.find_or_create_by(value: 'liquidated')
    liquidated.label_translations = {
      en: I18n.t('database.option_sets.loan_status.liquidated', locale: 'en'),
      es: I18n.t('database.option_sets.loan_status.liquidated', locale: 'es')
    }
    liquidated.save

    prospective = loan_status.options.find_or_create_by(value: 'prospective')
    prospective.label_translations = {
      en: I18n.t('database.option_sets.loan_status.prospective', locale: 'en'),
      es: I18n.t('database.option_sets.loan_status.prospective', locale: 'es')
    }
    prospective.save

    dormant_prospective = loan_status.options.find_or_create_by(value: 'dormant_prospective')
    dormant_prospective.label_translations = {
      en: I18n.t('database.option_sets.loan_status.dormant_prospective', locale: 'en'),
      es: I18n.t('database.option_sets.loan_status.dormant_prospective', locale: 'es')
    }
    dormant_prospective.save

    refinanced = loan_status.options.find_or_create_by(value: 'refinanced')
    refinanced.label_translations = {
      en: I18n.t('database.option_sets.loan_status.refinanced', locale: 'en'),
      es: I18n.t('database.option_sets.loan_status.refinanced', locale: 'es')
    }
    refinanced.save

    relationship = loan_status.options.find_or_create_by(value: 'relationship')
    relationship.label_translations = {
      en: I18n.t('database.option_sets.loan_status.relationship', locale: 'en'),
      es: I18n.t('database.option_sets.loan_status.relationship', locale: 'es')
    }
    relationship.save

    relationship_active = loan_status.options.find_or_create_by(value: 'relationship_active')
    relationship_active.label_translations = {
      en: I18n.t('database.option_sets.loan_status.relationship_active', locale: 'en'),
      es: I18n.t('database.option_sets.loan_status.relationship_active', locale: 'es')
    }
    relationship_active.save
  end

  def create_basic_project_status
    basic_project_status = OptionSet.find_or_create_by(division: Division.root,
      model_type: BasicProject.name, model_attribute: 'status')

    active = basic_project_status.options.find_or_create_by(value: 'active')
    active.label_translations = {
      en: I18n.t('database.option_sets.basic_project_status.active', locale: 'en'),
      es: I18n.t('database.option_sets.basic_project_status.active', locale: 'es')
    }
    active.save

    completed = basic_project_status.options.find_or_create_by(value: 'completed')
    completed.label_translations = {
      en: I18n.t('database.option_sets.basic_project_status.completed', locale: 'en'),
      es: I18n.t('database.option_sets.basic_project_status.completed', locale: 'es')
    }
    completed.save

    changed = basic_project_status.options.find_or_create_by(value: 'changed')
    changed.label_translations = {
      en: I18n.t('database.option_sets.basic_project_status.changed', locale: 'en'),
      es: I18n.t('database.option_sets.basic_project_status.changed', locale: 'es')
    }
    changed.save

    possible = basic_project_status.options.find_or_create_by(value: 'possible')
    possible.label_translations = {
      en: I18n.t('database.option_sets.basic_project_status.possible', locale: 'en'),
      es: I18n.t('database.option_sets.basic_project_status.possible', locale: 'es')
    }
    possible.save
  end

  def create_loan_type
    loan_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'loan_type')

    liquidity_loc = loan_type.options.find_or_create_by(value: 'liquidity_loc')
    liquidity_loc.label_translations = {
      en: I18n.t('database.option_sets.loan_type.liquidity_loc', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.liquidity_loc', locale: 'es')
    }
    liquidity_loc.save

    investment_loc = loan_type.options.find_or_create_by(value: 'investment_loc')
    investment_loc.label_translations = {
      en: I18n.t('database.option_sets.loan_type.investment_loc', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.investment_loc', locale: 'es')
    }
    investment_loc.save

    investment = loan_type.options.find_or_create_by(value: 'investment')
    investment.label_translations = {
      en: I18n.t('database.option_sets.loan_type.investment', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.investment', locale: 'es')
    }
    investment.save

    evolving = loan_type.options.find_or_create_by(value: 'evolving')
    evolving.label_translations = {
      en: I18n.t('database.option_sets.loan_type.evolving', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.evolving', locale: 'es')
    }
    evolving.save

    single_liquidity_loc = loan_type.options.find_or_create_by(value: 'single_liquidity_loc')
    single_liquidity_loc.label_translations = {
      en: I18n.t('database.option_sets.loan_type.single_liquidity_loc', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.single_liquidity_loc', locale: 'es')
    }
    single_liquidity_loc.save

    wc_investment = loan_type.options.find_or_create_by(value: 'wc_investment')
    wc_investment.label_translations = {
      en: I18n.t('database.option_sets.loan_type.wc_investment', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.wc_investment', locale: 'es')
    }
    wc_investment.save

    sa_investment = loan_type.options.find_or_create_by(value: 'sa_investment')
    sa_investment.label_translations = {
      en: I18n.t('database.option_sets.loan_type.sa_investment', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.sa_investment', locale: 'es')
    }
    sa_investment.save

    community_solar = loan_type.options.find_or_create_by(value: 'community_solar')
    community_solar.label_translations = {
      en: I18n.t('database.option_sets.loan_type.community_solar', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.community_solar', locale: 'es')
    }
    community_solar.save

    conversion_phased = loan_type.options.find_or_create_by(value: 'conversion_phased')
    conversion_phased.label_translations = {
      en: I18n.t('database.option_sets.loan_type.conversion_phased', locale: 'en'),
      es: I18n.t('database.option_sets.loan_type.conversion_phased', locale: 'es')
    }
    conversion_phased.save
  end

  def create_public_level
    public_level = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'public_level')

    public_option = public_level.options.find_or_create_by(value: 'public')
    public_option.label_translations = {
      en: I18n.t('database.option_sets.public_level.public', locale: 'en'),
      es: I18n.t('database.option_sets.public_level.public', locale: 'es')
    }
    public_option.save

    featured = public_level.options.find_or_create_by(value: 'featured')
    featured.label_translations = {
      en: I18n.t('database.option_sets.public_level.featured', locale: 'en'),
      es: I18n.t('database.option_sets.public_level.featured', locale: 'es')
    }
    featured.save

    hidden = public_level.options.find_or_create_by(value: 'hidden')
    hidden.label_translations = {
      en: I18n.t('database.option_sets.public_level.hidden', locale: 'en'),
      es: I18n.t('database.option_sets.public_level.hidden', locale: 'es')
    }
    hidden.save
  end

  def create_step_type
    step_type = OptionSet.find_or_create_by(division: Division.root, model_type: ProjectStep.name,
      model_attribute: 'step_type')

    checkin = step_type.options.find_or_create_by(value: 'checkin')
     checkin.label_translations = {
      en: I18n.t('database.option_sets.step_type.checkin', locale: 'en'),
      es: I18n.t('database.option_sets.step_type.checkin', locale: 'es')
    }
    checkin.save

    milestone = step_type.options.find_or_create_by(value: 'milestone')
    milestone.label_translations = {
      en: I18n.t('database.option_sets.step_type.milestone', locale: 'en'),
      es: I18n.t('database.option_sets.step_type.milestone', locale: 'es')
    }
    milestone.save
  end

  def create_progress_metric
    progress_metric = OptionSet.find_or_create_by(division: Division.root, model_type: ProjectLog.name,
      model_attribute: 'progress_metric')

    change_plan = progress_metric.options.find_or_create_by(migration_id: -3)
    change_plan.label_translations = {
      en: I18n.t('database.option_sets.progress_metric.change_plan', locale: 'en'),
      es: I18n.t('database.option_sets.progress_metric.change_plan', locale: 'es')
    }
    change_plan.save

    change_events = progress_metric.options.find_or_create_by(migration_id: -2)
    change_events.label_translations = {
      en: I18n.t('database.option_sets.progress_metric.change_events', locale: 'en'),
      es: I18n.t('database.option_sets.progress_metric.change_events', locale: 'es')
    }
    change_events.save

    behind = progress_metric.options.find_or_create_by(migration_id: -1)
    behind.label_translations = {
      en: I18n.t('database.option_sets.progress_metric.behind', locale: 'en'),
      es: I18n.t('database.option_sets.progress_metric.behind', locale: 'es')
    }
    behind.save

    on_time = progress_metric.options.find_or_create_by(migration_id: 1)
    on_time.label_translations = {
      en: I18n.t('database.option_sets.progress_metric.on_time', locale: 'en'),
      es: I18n.t('database.option_sets.progress_metric.on_time', locale: 'es')
    }
    on_time.save

    ahead = progress_metric.options.find_or_create_by(migration_id: 2)
    ahead.label_translations = {
      en: I18n.t('database.option_sets.progress_metric.ahead', locale: 'en'),
      es: I18n.t('database.option_sets.progress_metric.ahead', locale: 'es')
    }
    ahead.save
  end

  def create_media_kind
    media_kind = OptionSet.find_or_create_by(division: Division.root, model_type: Media.name,
      model_attribute: 'kind')

    image = media_kind.options.find_or_create_by(value: 'image')
    image.label_translations = {
      en: I18n.t('database.option_sets.media_kind.image', locale: 'en'),
      es: I18n.t('database.option_sets.media_kind.image', locale: 'es')
    }
    image.save

    video = media_kind.options.find_or_create_by(value: 'video')
    video.label_translations = {
      en: I18n.t('database.option_sets.media_kind.video', locale: 'en'),
      es: I18n.t('database.option_sets.media_kind.video', locale: 'es')
    }
    video.save

    document = media_kind.options.find_or_create_by(value: 'document')
    document.label_translations = {
      en: I18n.t('database.option_sets.media_kind.document', locale: 'en'),
      es: I18n.t('database.option_sets.media_kind.document', locale: 'es')
    }
    document.save

    contract = media_kind.options.find_or_create_by(value: 'contract')
    contract.label_translations = {
      en: I18n.t('database.option_sets.media_kind.contract', locale: 'en'),
      es: I18n.t('database.option_sets.media_kind.contract', locale: 'es')
    }
    contract.save
  end

  def create_loan_transaction_type
    loan_transaction_type = OptionSet.find_or_create_by(division: Division.root,
      model_type: Accounting::Transaction.name, model_attribute: 'loan_transaction_type')

    interest = loan_transaction_type.options.find_or_create_by(value: 'interest', position: 1)
    interest.label_translations = {
      en: I18n.t('database.option_sets.loan_transaction_type.interest', locale: 'en'),
      es: I18n.t('database.option_sets.loan_transaction_type.interest', locale: 'es')
    }
    interest.save

    disbursement = loan_transaction_type.options.find_or_create_by(value: 'disbursement', position: 2)
    disbursement.label_translations = {
      en: I18n.t('database.option_sets.loan_transaction_type.disbursement', locale: 'en'),
      es: I18n.t('database.option_sets.loan_transaction_type.disbursement', locale: 'es')
    }
    disbursement.save

    repayment = loan_transaction_type.options.find_or_create_by(value: 'repayment', position: 3)
    repayment.label_translations = {
      en: I18n.t('database.option_sets.loan_transaction_type.repayment', locale: 'en'),
      es: I18n.t('database.option_sets.loan_transaction_type.repayment', locale: 'es')
    }
    repayment.save

    other = loan_transaction_type.options.find_or_create_by(value: 'other', position: 4)
    other.label_translations = {
      en: I18n.t('database.option_sets.loan_transaction_type.other', locale: 'en'),
      es: I18n.t('database.option_sets.loan_transaction_type.other', locale: 'es')
    }
    other.save
  end

  def create_organization_inception
    organization_inception = OptionSet.find_or_create_by(division: Division.root,
      model_type: Organization.name, model_attribute: 'inception')

    startup = organization_inception.options.find_or_create_by(value: 'startup', position: 1)
    startup.label_translations = {
      en: I18n.t('database.option_sets.organization_inception.startup', locale: 'en'),
      es: I18n.t('database.option_sets.organization_inception.startup', locale: 'es')
    }
    startup.save

    conversion = organization_inception.options.find_or_create_by(value: 'conversion', position: 2)
    conversion.label_translations = {
      en: I18n.t('database.option_sets.organization_inception.conversion', locale: 'en'),
      es: I18n.t('database.option_sets.organization_inception.conversion', locale: 'es')
    }
    conversion.save

    recovered = organization_inception.options.find_or_create_by(value: 'recovered', position: 3)
    recovered.label_translations = {
      en: I18n.t('database.option_sets.organization_inception.recovered', locale: 'en'),
      es: I18n.t('database.option_sets.organization_inception.recovered', locale: 'es')
    }
    recovered.save
  end
end
