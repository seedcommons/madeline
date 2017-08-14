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
    loan_status.options.destroy_all
    loan_status.options.create(value: 'active', label_translations: {
        en: 'Active',
        es: 'Prestamo Activo'
      })
    loan_status.options.create(value: 'completed', label_translations: {
        en: 'Completed',
        es: 'Prestamo Completo'
      })
    loan_status.options.create(value: 'frozen', label_translations: {
        en: 'Frozen',
        es: 'Prestamo Congelado'
      })
    loan_status.options.create(value: 'liquidated', label_translations: {
        en: 'Liquidated',
        es: 'Prestamo Liquidado'
      })
    loan_status.options.create(value: 'prospective', label_translations: {
        en: 'Prospective',
        es: 'Prestamo Prospectivo'
      })
    loan_status.options.create(value: 'refinanced', label_translations: {
        en: 'Refinanced',
        es: 'Prestamo Refinanciado'
      })
    loan_status.options.create(value: 'relationship', label_translations: {
        en: 'Relationship',
        es: 'Relacion'
      })
    loan_status.options.create(value: 'relationship_active', label_translations: {
        en: 'Relationship Active',
        es: 'Relacion Activo'
      })
  end

  def create_basic_project_status
    basic_project_status = OptionSet.find_or_create_by(division: Division.root,
      model_type: BasicProject.name, model_attribute: 'status')
    basic_project_status.options.destroy_all
    basic_project_status.options.create(value: 'active', label_translations: {
        en: 'Active',
        es: 'Activo'
      })
    basic_project_status.options.create(value: 'completed', label_translations: {
        en: 'Completed',
        es: 'Completo'
      })
    basic_project_status.options.create(value: 'changed', label_translations: {
        en: 'Changed',
        es: 'Cambiado'
      })
    basic_project_status.options.create(value: 'possible', label_translations: {
        en: 'Possible',
        es: 'Posible'
      })
  end

  def create_loan_type
    loan_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'loan_type')
    loan_type.options.destroy_all
    loan_type.options.create(migration_id: 1, label_translations: {
        en: 'Liquidity line of credit',
        es: 'Línea de crédito de efectivo'
      })
    loan_type.options.create(migration_id: 2, label_translations: {
        en: 'Investment line of credit',
        es: 'Línea de crédito de inversión'
      })
    loan_type.options.create(migration_id: 3, label_translations: {
        en: 'Investment Loans',
        es: 'Préstamo de Inversión'
      })
    loan_type.options.create(migration_id: 4, label_translations: {
        en: 'Evolving loan',
        es: 'Préstamo de evolución'
      })
    loan_type.options.create(migration_id: 5, label_translations: {
        en: 'Single Liquidity line of credit',
        es: 'Línea puntual de crédito de efectivo'
      })
    loan_type.options.create(migration_id: 6, label_translations: {
        en: 'Working Capital Investment Loan',
        es: 'Préstamo de Inversión de Capital de Trabajo'
      })
    loan_type.options.create(migration_id: 7, label_translations: {
        en: 'Secured Asset Investment Loan',
        es: 'Préstamo de Inversión de Bienes Asegurados'
      })
  end

  def create_public_level
    public_level = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
      model_attribute: 'public_level')
    public_level.options.destroy_all
    public_level.options.create(value: 'featured', label_translations: {
        en: 'Featured',
        es: 'TODO'
      })
    public_level.options.create(value: 'hidden', label_translations: {
        en: 'Hidden',
        es: 'TODO'
      })
  end

  def create_step_type
    step_type = OptionSet.find_or_create_by(division: Division.root, model_type: ProjectStep.name,
      model_attribute: 'step_type')
    step_type.options.destroy_all
    step_type.options.create(value: 'checkin', label_translations: {
        en: 'Check-in',
        es: 'Paso'
      })
    step_type.options.create(value: 'milestone', label_translations: {
        en: 'Milestone',
        es: 'Hito'
      })
  end

  def create_progress_metric
    progress_metric = OptionSet.find_or_create_by(division: Division.root, model_type: ProjectLog.name,
      model_attribute: 'progress_metric')
    progress_metric.options.destroy_all
    progress_metric.options.create(migration_id: -3, label_translations: {
        en: 'In need of changing its whole plan',
        es: 'Con necesidad de cambiar su plan completamente'
      })
    progress_metric.options.create(migration_id: -2, label_translations: {
        en: 'In need of changing some events',
        es: 'Con necesidad de cambiar algunos eventos'
      })
    progress_metric.options.create(migration_id: -1, label_translations: {
        en: 'Behind',
        es: 'Atrasado'
      })
    progress_metric.options.create(migration_id: 1, label_translations: {
        en: 'On time',
        es: 'A tiempo'
      })
    progress_metric.options.create(migration_id: 2, label_translations: {
        en: 'Ahead',
        es: 'Adelantado'
      })
  end

  def create_media_kind
    media_kind = OptionSet.find_or_create_by(division: Division.root, model_type: Media.name,
      model_attribute: 'kind')
    media_kind.options.destroy_all
    media_kind.options.create(value: 'image', label_translations: {
        en: 'Image',
        es: 'Imagen'
      })
    media_kind.options.create(value: 'video', label_translations: {
        en: 'Video',
        es: 'Vídeo'
      })
    media_kind.options.create(value: 'document', label_translations: {
        en: 'Document',
        es: 'Documento'
      })
    media_kind.options.create(value: 'contract', label_translations: {
        en: 'Contract',
        es: 'Contrato'
      })
  end

  def create_loan_transaction_type
    loan_transaction_type = OptionSet.find_or_create_by(division: Division.root,
      model_type: Accounting::Transaction.name, model_attribute: 'loan_transaction_type')
    loan_transaction_type.options.destroy_all
    loan_transaction_type.options.create(value: 'interest', position: 1, label_translations: {
        en: 'Interest',
        es: 'Interés'
      })
    loan_transaction_type.options.create(value: 'disbursement', position: 2, label_translations: {
        en: 'Disbursement',
        es: 'Desembolso'
      })
    loan_transaction_type.options.create(value: 'repayment', position: 3, label_translations: {
        en: 'Repayment',
        es: 'Reembolso'
      })
  end
end
