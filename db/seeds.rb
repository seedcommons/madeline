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

OptionSetCreator.new.create_all

loan_transaction_type = OptionSet.find_or_create_by(division: Division.root, model_type: Loan.name,
  model_attribute: 'loan_transaction_type')
loan_transaction_type.options.destroy_all
loan_transaction_type.options.create(value: 'interest', position: 1,
  label_translations: {en: 'Interest', es: 'Interés'})
loan_transaction_type.options.create(value: 'disbursement', position: 2,
  label_translations: {en: 'Disbursement', es: 'Desembolso'})
loan_transaction_type.options.create(value: 'repayment', position: 3,
  label_translations: {en: 'Repayment', es: 'Reembolso'})

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
