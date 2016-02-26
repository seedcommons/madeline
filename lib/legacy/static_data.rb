module Legacy

  class StaticData

    def self.populate
      # ::Division.create(id: 99, internal_name: ::Division.root_internal_name, name: 'Root Division')  unless ::Division.find_by(internal_name: ::Division.root_internal_name)
      ::Division.create(id: 99, name: 'Root Division')  unless ::Division.root
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

      # Note, the option sets are expected to be included in seeds.rb
      loan_type = OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'loan_type')
      loan_type.options.destroy_all

      # Note, there is currently no business logic dependency on these options, # so no need for a 'slug' style value.
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
      step_type.options.create(value: 'step', label_translations: {en: 'Step', es: 'Paso'})
      step_type.options.create(value: 'milestone', label_translations: {en: 'Milestone', es: 'TODO'})
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

      CustomFieldSet.find_or_create_by(id: 1, division: Division.root, internal_name: 'old_loan_criteria').set_label('Old Loan Criteria Questionnaire')
      CustomFieldSet.find_or_create_by(id: 2, division: Division.root, internal_name: 'loan_criteria').set_label('Loan Criteria Questionnaire')
      CustomFieldSet.find_or_create_by(id: 3, division: Division.root, internal_name: 'loan_post_analysis').set_label('Loan Post Analysis')
      CustomFieldSet.recalibrate_sequence(gap: 10)

      # need to leave room for migrated loan questions
      CustomField.recalibrate_sequence(id: 200)

      org_field_set = CustomFieldSet.find_or_create_by(division: Division.root, internal_name: 'Organization')
      org_field_set.custom_fields.destroy_all
      org_field_set.custom_fields.create!(internal_name: 'is_recovered', data_type: 'boolean')
      org_field_set.custom_fields.create!(internal_name: 'dynamic_translatable_test', data_type: 'translatable')

      # loan_field_set = CustomFieldSet.find_or_create_by(division: Division.root, internal_name: 'Loan')
      # loan_field_set.custom_fields.destroy_all
      # loan_field_set.custom_fields.create!(internal_name: 'old_loan_criteria_id', data_type: 'number')

    end


    # useful to remove the above data so that it can be re-run in isolation
    def self.purge
      Country.destroy_all rescue nil
      Currency.destroy_all rescue nil
      OptionSet.destroy_all rescue nil
    end


    def self.handy_test_data
      user = ::User.create!({email: 'john@doe.com', password: 'xxxxxxxx', password_confirmation: 'xxxxxxxx'})

      # division = Division.create(name: 'Test Division', parent_id: Division.root_id)
      # for now just use the root division
      division = ::Division.root

      org = ::Organization.create!(name: 'Test Co-op', division: division)
      person = ::Person.create!(first_name: 'John', last_name: 'Doe', primary_organization: org, division: division)
      loan = ::Loan.create!(organization: org,
                          loan_type_value: ::Loan.loan_type_option_set.value_for_migration_id(6),
                          status_value: :active, division: division)

      step = ::ProjectStep.create!(project: loan, summary: "test step", step_type_value: :step)
      step_log = ::ProjectLog.create!(project_step: step,
                                    progress_metric_value: ::ProjectLog.progress_metric_option_set.value_for_migration_id(-1),
                                    summary: 'test log summary', details: 'test log details')
      step2 = ::ProjectStep.create!(project: loan, summary: "test milestone", step_type_value: :milestone)

    end

  end


end
