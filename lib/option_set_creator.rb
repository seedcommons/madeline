class OptionSetCreator
  def create_all
    create_loan_status
    create_basic_project_status
    create_loan_type
    create_public_level
    create_step_type
    create_progress_metric
    create_media_kind
    create_loan_transaction_type
  end

  def create_loan_status
    loan_status = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'status')
    loan_status.options.find_or_create_by(value: 'active', label_translations: {
        en: I18n.t('database.option_sets.loan_status.active', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.active', locale: 'es')
      })
    loan_status.options.find_or_create_by(value: 'completed', label_translations: {
        en: I18n.t('database.option_sets.loan_status.completed', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.completed', locale: 'es')
      })
    loan_status.options.find_or_create_by(value: 'frozen', label_translations: {
        en: I18n.t('database.option_sets.loan_status.frozen', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.frozen', locale: 'es')
      })
    loan_status.options.find_or_create_by(value: 'liquidated', label_translations: {
        en: I18n.t('database.option_sets.loan_status.liquidated', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.liquidated', locale: 'es')
      })
    loan_status.options.find_or_create_by(value: 'prospective', label_translations: {
        en: I18n.t('database.option_sets.loan_status.prospective', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.prospective', locale: 'es')
      })
    loan_status.options.find_or_create_by(value: 'refinanced', label_translations: {
        en: I18n.t('database.option_sets.loan_status.refinanced', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.refinanced', locale: 'es')
      })
    loan_status.options.find_or_create_by(value: 'relationship', label_translations: {
        en: I18n.t('database.option_sets.loan_status.relationship', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.relationship', locale: 'es')
      })
    loan_status.options.find_or_create_by(value: 'relationship_active', label_translations: {
        en: I18n.t('database.option_sets.loan_status.relationship_active', locale: 'en'),
        es: I18n.t('database.option_sets.loan_status.relationship_active', locale: 'es')
      })
  end

  def create_basic_project_status
    basic_project_status = OptionSet.find_or_create_by(division: Division.root,
      model_type: BasicProject.name, model_attribute: 'status')
    basic_project_status.options.destroy_all
    basic_project_status.options.create(value: 'active', label_translations: {
        en: I18n.t('database.option_sets.basic_project_status.active', locale: 'en'),
        es: I18n.t('database.option_sets.basic_project_status.active', locale: 'es')
      })
    basic_project_status.options.create(value: 'completed', label_translations: {
        en: I18n.t('database.option_sets.basic_project_status.completed', locale: 'en'),
        es: I18n.t('database.option_sets.basic_project_status.completed', locale: 'es')
      })
    basic_project_status.options.create(value: 'changed', label_translations: {
        en: I18n.t('database.option_sets.basic_project_status.changed', locale: 'en'),
        es: I18n.t('database.option_sets.basic_project_status.changed', locale: 'es')
      })
    basic_project_status.options.create(value: 'possible', label_translations: {
        en: I18n.t('database.option_sets.basic_project_status.possible', locale: 'en'),
        es: I18n.t('database.option_sets.basic_project_status.possible', locale: 'es')
      })
  end

  def create_loan_type
    loan_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'loan_type')
    loan_type.options.destroy_all
    loan_type.options.create(migration_id: 1, value: 'liquidity_loc', label_translations: {
        en: I18n.t('database.option_sets.loan_type.liquidity_loc', locale: 'en'),
        es: I18n.t('database.option_sets.loan_type.liquidity_loc', locale: 'es')
      })
    loan_type.options.create(migration_id: 2, value: 'investment_loc', label_translations: {
        en: I18n.t('database.option_sets.loan_type.investment_loc', locale: 'en'),
        es: I18n.t('database.option_sets.loan_type.investment_loc', locale: 'es')
      })
    loan_type.options.create(migration_id: 3, value: 'investment', label_translations: {
        en: I18n.t('database.option_sets.loan_type.investment', locale: 'en'),
        es: I18n.t('database.option_sets.loan_type.investment', locale: 'es')
      })
    loan_type.options.create(migration_id: 4, value: 'evolving', label_translations: {
        en: I18n.t('database.option_sets.loan_type.evolving', locale: 'en'),
        es: I18n.t('database.option_sets.loan_type.evolving', locale: 'es')
      })
    loan_type.options.create(migration_id: 5, value: 'single_liquidity_loc', label_translations: {
        en: I18n.t('database.option_sets.loan_type.single_liquidity_loc', locale: 'en'),
        es: I18n.t('database.option_sets.loan_type.single_liquidity_loc', locale: 'es')
      })
    loan_type.options.create(migration_id: 6, value: 'wc_investment', label_translations: {
        en: I18n.t('database.option_sets.loan_type.wc_investment', locale: 'en'),
        es: I18n.t('database.option_sets.loan_type.wc_investment', locale: 'es')
      })
    loan_type.options.create(migration_id: 7, value: 'sa_investment', label_translations: {
        en: I18n.t('database.option_sets.loan_type.sa_investment', locale: 'en'),
        es: I18n.t('database.option_sets.loan_type.sa_investment', locale: 'es')
      })
  end

  def create_public_level
    public_level = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'public_level')

    Option.find_or_create_by(option_set_id: public_level.id, value: 'featured') do |option|
      option.label_translations.en = I18n.t('database.option_sets.public_level.featured', locale: 'en')
      option.label_translations.es = I18n.t('database.option_sets.public_level.featured', locale: 'es')
    end

    Option.find_or_create_by(option_set_id: public_level.id, value: 'hidden') do |option|
      option.label_translations.en = I18n.t('database.option_sets.public_level.hidden', locale: 'en')
      option.label_translations.es = I18n.t('database.option_sets.public_level.hidden', locale: 'es')
    end
  end

  def create_step_type
    step_type = OptionSet.find_or_create_by(division: Division.root, model_type: ProjectStep.name,
      model_attribute: 'step_type')
    step_type.options.destroy_all
    step_type.options.create(value: 'checkin', label_translations: {
        en: I18n.t('database.option_sets.step_type.checkin', locale: 'en'),
        es: I18n.t('database.option_sets.step_type.checkin', locale: 'es')
      })
    step_type.options.create(value: 'milestone', label_translations: {
        en: I18n.t('database.option_sets.step_type.milestone', locale: 'en'),
        es: I18n.t('database.option_sets.step_type.milestone', locale: 'es')
      })
  end

  def create_progress_metric
    progress_metric = OptionSet.find_or_create_by(division: Division.root, model_type: ProjectLog.name,
      model_attribute: 'progress_metric')
    progress_metric.options.destroy_all
    progress_metric.options.create(migration_id: -3, label_translations: {
        en: I18n.t('database.option_sets.progress_metric.change_plan', locale: 'en'),
        es: I18n.t('database.option_sets.progress_metric.change_plan', locale: 'es')
      })
    progress_metric.options.create(migration_id: -2, label_translations: {
        en: I18n.t('database.option_sets.progress_metric.change_events', locale: 'en'),
        es: I18n.t('database.option_sets.progress_metric.change_events', locale: 'es')
      })
    progress_metric.options.create(migration_id: -1, label_translations: {
        en: I18n.t('database.option_sets.progress_metric.behind', locale: 'en'),
        es: I18n.t('database.option_sets.progress_metric.behind', locale: 'es')
      })
    progress_metric.options.create(migration_id: 1, label_translations: {
        en: I18n.t('database.option_sets.progress_metric.on_time', locale: 'en'),
        es: I18n.t('database.option_sets.progress_metric.on_time', locale: 'es')
      })
    progress_metric.options.create(migration_id: 2, label_translations: {
        en: I18n.t('database.option_sets.progress_metric.ahead', locale: 'en'),
        es: I18n.t('database.option_sets.progress_metric.ahead', locale: 'es')
      })
  end

  def create_media_kind
    media_kind = OptionSet.find_or_create_by(division: Division.root, model_type: Media.name,
      model_attribute: 'kind')
    media_kind.options.destroy_all
    media_kind.options.create(value: 'image', label_translations: {
        en: I18n.t('database.option_sets.media_kind.image', locale: 'en'),
        es: I18n.t('database.option_sets.media_kind.image', locale: 'es')
      })
    media_kind.options.create(value: 'video', label_translations: {
        en: I18n.t('database.option_sets.media_kind.video', locale: 'en'),
        es: I18n.t('database.option_sets.media_kind.video', locale: 'es')
      })
    media_kind.options.create(value: 'document', label_translations: {
        en: I18n.t('database.option_sets.media_kind.document', locale: 'en'),
        es: I18n.t('database.option_sets.media_kind.document', locale: 'es')
      })
    media_kind.options.create(value: 'contract', label_translations: {
        en: I18n.t('database.option_sets.media_kind.contract', locale: 'en'),
        es: I18n.t('database.option_sets.media_kind.contract', locale: 'es')
      })
  end

  def create_loan_transaction_type
    loan_transaction_type = OptionSet.find_or_create_by(division: Division.root,
      model_type: Accounting::Transaction.name, model_attribute: 'loan_transaction_type')
    loan_transaction_type.options.destroy_all
    loan_transaction_type.options.create(value: 'interest', position: 1, label_translations: {
        en: I18n.t('database.option_sets.loan_transaction_type.interest', locale: 'en'),
        es: I18n.t('database.option_sets.loan_transaction_type.interest', locale: 'es'),
      })
    loan_transaction_type.options.create(value: 'disbursement', position: 2, label_translations: {
        en: I18n.t('database.option_sets.loan_transaction_type.disbursement', locale: 'en'),
        es: I18n.t('database.option_sets.loan_transaction_type.disbursement', locale: 'es')
      })
    loan_transaction_type.options.create(value: 'repayment', position: 3, label_translations: {
        en: I18n.t('database.option_sets.loan_transaction_type.repayment', locale: 'en'),
        es: I18n.t('database.option_sets.loan_transaction_type.repayment', locale: 'es')
      })
  end
end
