module Legacy

  class StaticData

    def self.populate
      # attempt to delete the seeds.rb created root division if exists, so this script will work after a freshly created db.
      # note, this will likely fail if anything else in the current database has been created
      ::Division.root.destroy  if ::Division.root.present?

      ::Division.create(id: 99, name: '-')  unless ::Division.root
      ::Division.recalibrate_sequence(gap: 1)

      Currency.find_or_create_by(id: 1, name: 'Argentinean Peso', code: 'ARS', symbol: 'AR$')
      Currency.find_or_create_by(id: 2, name: 'U.S. Dollar', code: 'USD', symbol: 'US$')
      Currency.find_or_create_by(id: 3, name: 'British Pound', code: 'GBP', symbol: 'GB£')
      Currency.find_or_create_by(id: 4, name: 'Nicaraguan Cordoba', code: 'NIO', symbol: 'NI$')
      Currency.recalibrate_sequence


      Country.find_or_create_by(id: 1, name: 'Argentina', iso_code: 'AR', default_currency_id: 1)
      Country.find_or_create_by(id: 2, name: 'Nicaragua', iso_code: 'NI', default_currency_id: 4)
      Country.find_or_create_by(id: 3, name: 'United States', iso_code: 'US', default_currency_id: 2)
      Country.recalibrate_sequence


      # The option set and the first two options are expected to be already populated by seeds.rb
      loan_status = OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'status')
      loan_status.options.destroy_all
      loan_status.options.create(value: 'active', label_translations: {en: 'Active', es: 'Prestamo Activo'})
      loan_status.options.create(value: 'completed', label_translations: {en: 'Completed', es: 'Prestamo Completo'})
      loan_status.options.create(value: 'frozen', label_translations: {en: 'Frozen', es: 'Prestamo Congelado'})
      loan_status.options.create(value: 'liquidated', label_translations: {en: 'Liquidated', es: 'Prestamo Liquidado'})
      loan_status.options.create(value: 'prospective', label_translations: {en: 'Prospective', es: 'Prestamo Prospectivo'})
      loan_status.options.create(value: 'refinanced', label_translations: {en: 'Refinanced', es: 'Prestamo Refinanciado'})
      loan_status.options.create(value: 'relationship', label_translations: {en: 'Relationship', es: 'Relacion'})
      loan_status.options.create(value: 'relationship_active',
          label_translations: {en: 'Relationship Active', es: 'Relacion Activo'})

      OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'loan_type')

      project_type = OptionSet.find_or_create_by(
          division: ::Division.root, model_type: ::Loan.name, model_attribute: 'project_type')
      project_type.options.destroy_all

      project_type.options.create(value: 'conversion', label_translations: {en: 'Conversion', es: 'TODO'})
      project_type.options.create(value: 'expansion', label_translations: {en: 'Expansion', es: 'TODO'})
      project_type.options.create(value: 'startup', label_translations: {en: 'Start-up', es: 'TODO'})


      public_level = OptionSet.find_or_create_by(
          division: ::Division.root, model_type: ::Loan.name, model_attribute: 'public_level')
      public_level.options.destroy_all
      public_level.options.create(value: 'featured', label_translations: {en: 'Featured', es: 'TODO'})
      public_level.options.create(value: 'hidden', label_translations: {en: 'Hidden', es: 'TODO'})


      step_type = OptionSet.find_or_create_by(
          division: ::Division.root, model_type: ::ProjectStep.name, model_attribute: 'step_type')
      step_type.options.destroy_all
      step_type.options.create(value: 'checkin', label_translations: {en: 'Check-in', es: 'Paso'})
      step_type.options.create(value: 'milestone', label_translations: {en: 'Milestone', es: 'Hito'}) #todo: confirm translation
      # legacy data exists of type 'Agenda', but not expecting to carry this forward into the new system
      # step_type.options.create(value: 'agenda', label_translations: {en: 'Agenda', es: 'TODO'})


      progress_metric = OptionSet.find_or_create_by(
          division: ::Division.root, model_type: ::ProjectLog.name, model_attribute: 'progress_metric')
      progress_metric.options.destroy_all
      progress_metric.options.create(migration_id: -3,
          label_translations: {en: 'in need of changing its whole plan', es: 'con necesidad de cambiar su plan completamente'})
      progress_metric.options.create(migration_id: -2,
          label_translations: {en: 'in need of changing some events', es: 'con necesidad de cambiar algunos eventos'})
      progress_metric.options.create(migration_id: -1, label_translations: {en: 'behind', es: 'atrasado'})
      progress_metric.options.create(migration_id: 1, label_translations: {en: 'on time', es: 'a tiempo'})
      progress_metric.options.create(migration_id: 2, label_translations: {en: 'ahead', es: 'adelantado'})

      # LoanQuestionSet.find_or_create_by(id: 1, division: Division.root, internal_name: 'old_loan_criteria').set_label('Old Loan Criteria Questionnaire')
      LoanQuestionSet.find_or_create_by(id: 2, division: Division.root, internal_name: 'loan_criteria').set_label('Loan Criteria Questionnaire')
      LoanQuestionSet.find_or_create_by(id: 3, division: Division.root, internal_name: 'loan_post_analysis').set_label('Loan Post Analysis')
      # Todo: Find out what this new question represents
      # LoanQuestionSet.find_or_create_by(id: 4, division: Division.root, internal_name: 'fourth_question_set').set_label('Fourth Question Set')
      LoanQuestionSet.recalibrate_sequence(gap: 10)

      # need to leave room for migrated loan questions
      LoanQuestion.recalibrate_sequence(id: 200)
    end


    # useful to remove the above data so that it can be re-run in isolation
    def self.purge
      Country.destroy_all rescue nil
      Currency.destroy_all rescue nil
      OptionSet.destroy_all rescue nil
    end
  end
end
