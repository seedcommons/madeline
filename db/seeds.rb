# This is generic data that is needed for any instance of this app to work properly.
# It should not be specific to a particular instance.

Division.root.destroy if Division.root.present?
Division.create(id: 99, name: 'Root Division') unless Division.root
Division.recalibrate_sequence(gap: 1)

Currency.find_or_create_by(id: 1, name: 'Argentinean Peso', code: 'ARS', symbol: 'AR$')
Currency.find_or_create_by(id: 2, name: 'U.S. Dollar', code: 'USD', symbol: 'US$')
Currency.find_or_create_by(id: 3, name: 'British Pound', code: 'GBP', symbol: 'GB£')
Currency.find_or_create_by(id: 4, name: 'Nicaraguan Cordoba', code: 'NIO', symbol: 'NI$')
Currency.recalibrate_sequence

Country.find_or_create_by(id: 1, name: 'Argentina', iso_code: 'AR', default_currency_id: 1)
Country.find_or_create_by(id: 2, name: 'Nicaragua', iso_code: 'NI', default_currency_id: 4)
Country.find_or_create_by(id: 3, name: 'United States', iso_code: 'US', default_currency_id: 2)
Country.recalibrate_sequence

loan_status = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
  model_attribute: 'status')
loan_status.options.destroy_all
loan_status.options.create(value: 'active',
  label_translations: {en: 'Active', es: 'Prestamo Activo'})
loan_status.options.create(value: 'completed',
  label_translations: {en: 'Completed', es: 'Prestamo Completo'})
loan_status.options.create(value: 'frozen',
  label_translations: {en: 'Frozen', es: 'Prestamo Congelado'})
loan_status.options.create(value: 'liquidated',
  label_translations: {en: 'Liquidated', es: 'Prestamo Liquidado'})
loan_status.options.create(value: 'prospective',
  label_translations: {en: 'Prospective', es: 'Prestamo Prospectivo'})
loan_status.options.create(value: 'refinanced',
  label_translations: {en: 'Refinanced', es: 'Prestamo Refinanciado'})
loan_status.options.create(value: 'relationship',
  label_translations: {en: 'Relationship', es: 'Relacion'})
loan_status.options.create(value: 'relationship_active',
    label_translations: {en: 'Relationship Active', es: 'Relacion Activo'})

basic_project_status = OptionSet.find_or_create_by(division: Division.root, model_type: BasicProject.name,
  model_attribute: 'status')
basic_project_status.options.destroy_all
basic_project_status.options.create(value: 'active',
  label_translations: {en: 'Active', es: 'Activo'})
basic_project_status.options.create(value: 'completed',
  label_translations: {en: 'Completed', es: 'Completo'})
basic_project_status.options.create(value: 'changed',
  label_translations: {en: 'Changed', es: 'Cambiado'})
basic_project_status.options.create(value: 'possible',
  label_translations: {en: 'Possible', es: 'Posible'})

loan_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name, model_attribute: 'loan_type')
loan_type.options.destroy_all

# Note, there is currently no business logic dependency on these options, so no need for a 'slug' style value.
# Instead the primary key will be used by default, and the legacy data will be matched up by migration_id.
# If there is a need, then 'slug' style values can be introduced.
loan_type.options.create(migration_id: 1,
    label_translations: {en: 'Liquidity line of credit', es: 'Línea de crédito de efectivo'})
loan_type.options.create(migration_id: 2,
    label_translations: {en: 'Investment line of credit', es: 'Línea de crédito de inversión'})
loan_type.options.create(migration_id: 3,
    label_translations: {en: 'Investment Loans', es: 'Préstamo de Inversión'})
loan_type.options.create(migration_id: 4,
    label_translations: {en: 'Evolving loan', es: 'Préstamo de evolución'})
loan_type.options.create(migration_id: 5,
    label_translations: {en: 'Single Liquidity line of credit', es: 'Línea puntual de crédito de efectivo'})
loan_type.options.create(migration_id: 6,
    label_translations: {en: 'Working Capital Investment Loan', es: 'Préstamo de Inversión de Capital de Trabajo'})
loan_type.options.create(migration_id: 7,
    label_translations: {en: 'Secured Asset Investment Loan', es: 'Préstamo de Inversión de Bienes Asegurados'})

project_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
  model_attribute: 'project_type')
project_type.options.destroy_all
project_type.options.create(value: 'conversion', label_translations: {en: 'Conversion', es: 'TODO'})
project_type.options.create(value: 'expansion', label_translations: {en: 'Expansion', es: 'TODO'})
project_type.options.create(value: 'startup', label_translations: {en: 'Start-up', es: 'TODO'})

public_level = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
  model_attribute: 'public_level')
public_level.options.destroy_all
public_level.options.create(value: 'featured', label_translations: {en: 'Featured', es: 'TODO'})
public_level.options.create(value: 'hidden', label_translations: {en: 'Hidden', es: 'TODO'})

step_type = OptionSet.find_or_create_by(division: Division.root, model_type: ProjectStep.name,
  model_attribute: 'step_type')
step_type.options.destroy_all
step_type.options.create(value: 'checkin', label_translations: {en: 'Check-in', es: 'Paso'})
step_type.options.create(value: 'milestone', label_translations: {en: 'Milestone', es: 'Hito'})

progress_metric = OptionSet.find_or_create_by(division: Division.root, model_type: ProjectLog.name,
  model_attribute: 'progress_metric')
progress_metric.options.destroy_all
progress_metric.options.create(migration_id: -3, label_translations:
  {en: 'In need of changing its whole plan', es: 'Con necesidad de cambiar su plan completamente'})
progress_metric.options.create(migration_id: -2, label_translations:
  {en: 'In need of changing some events', es: 'Con necesidad de cambiar algunos eventos'})
progress_metric.options.create(migration_id: -1, label_translations: {en: 'Behind', es: 'Atrasado'})
progress_metric.options.create(migration_id: 1, label_translations: {en: 'On time', es: 'A tiempo'})
progress_metric.options.create(migration_id: 2, label_translations: {en: 'Ahead', es: 'Adelantado'})

# Need to leave room for migrated loan questions
# Can remove this line once migration is over with.
LoanQuestion.recalibrate_sequence(id: 300)

# Without these resets we were getting a strange closure_tree error.
LoanQuestionSet.connection.schema_cache.clear!
LoanQuestionSet.reset_column_information

LoanQuestionSet.find_or_create_by(id: 2, division: Division.root,
  internal_name: 'loan_criteria').set_label('Loan Criteria Questionnaire')
LoanQuestionSet.find_or_create_by(id: 3, division: Division.root,
  internal_name: 'loan_post_analysis').set_label('Loan Post Analysis')
LoanQuestionSet.recalibrate_sequence(gap: 10)
