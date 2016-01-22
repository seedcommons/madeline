module Legacy

  class StaticData

    def self.populate
      ::Division.create(id: 99, internal_name: ::Division.root_internal_name, name: 'Root Division')  unless ::Division.find_by(internal_name: ::Division.root_internal_name)
      ::Division.recalibrate_sequence(gap: 1)

      Language.find_or_create_by(id: 1, name: 'English', code: 'EN')
      Language.find_or_create_by(id: 2, name: 'Español', code: 'ES')
      Language.find_or_create_by(id: 3, name: 'Français', code: 'FR')
      Language.recalibrate_sequence


      Currency.find_or_create_by(id: 1, name: 'Argentinean Peso', code: 'ARS', symbol: 'AR$')
      Currency.find_or_create_by(id: 2, name: 'U.S. Dollar', code: 'USD', symbol: 'US$')
      Currency.find_or_create_by(id: 3, name: 'British Pound', code: 'GBP', symbol: 'GB£')
      Currency.find_or_create_by(id: 4, name: 'Nicaraguan Cordoba', code: 'NIO', symbol: 'NI$')
      Currency.recalibrate_sequence


      Country.find_or_create_by(id: 1, name: 'Argentina', iso_code: 'AR', default_language_id: 2, default_currency_id: 1)
      Country.find_or_create_by(id: 2, name: 'Nicaragua', iso_code: 'NI', default_language_id: 2, default_currency_id: 4)
      Country.find_or_create_by(id: 3, name: 'United States', iso_code: 'US', default_language_id: 1, default_currency_id: 2)
      Country.recalibrate_sequence


      # The option set and the first two options are expected to be already populated by seeds.rb
      loan_status = OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'status')
      loan_status.options.destroy_all
      loan_status.create_option(value: 'active').set_label_list(en: 'Active', es: 'Prestamo Activo')
      loan_status.create_option(value: 'completed').set_label_list(en: 'Completed', es: 'Prestamo Completo')
      loan_status.create_option(value: 'frozen').set_label_list(en: 'Frozen', es: 'Prestamo Congelado')
      loan_status.create_option(value: 'liquidated').set_label_list(en: 'Liquidated', es: 'Prestamo Liquidado')
      loan_status.create_option(value: 'prospective').set_label_list(en: 'Prospective', es: 'Prestamo Prospectivo')
      loan_status.create_option(value: 'refinanced').set_label_list(en: 'Refinanced', es: 'Prestamo Refinanciado')
      loan_status.create_option(value: 'relationship').set_label_list(en: 'Relationship', es: 'Relacion')
      loan_status.create_option(value: 'relationship_active').
          set_label_list(en: 'Relationship Active', es: 'Relacion Activo')

      # Note, the option sets are expected to be included in seeds.rb
      loan_type = OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'loan_type')
      loan_type.options.destroy_all

      # Note, there is currently no business logic dependency on these options, # so no need for a 'slug' style value.
      # Instead the primary key will be used by default, and the legacy data will be matched up by migration_id.
      # If there is a need, then 'slug' style values can be introduced.
      loan_type.create_option(migration_id: 1).
          set_label_list(en: 'Liquidity line of credit', es: 'Línea de crédito de efectivo')

      loan_type.create_option(migration_id: 2).
          set_label_list(en: 'Investment line of credit', es: 'Línea de crédito de inversión')

      loan_type.create_option(migration_id: 3).
          set_label_list(en: 'Investment Loans', es: 'Préstamo de Inversión')

      loan_type.create_option(migration_id: 4).
          set_label_list(en: 'Evolving loan', es: 'Préstamo de evolución')

      loan_type.create_option(migration_id: 5).
          set_label_list(en: 'Single Liquidity line of credit', es: 'Línea puntual de crédito de efectivo')

      loan_type.create_option(migration_id: 6).
          set_label_list(en: 'Working Capital Investment Loan', es: 'Préstamo de Inversión de Capital de Trabajo')

      loan_type.create_option(migration_id: 7).
          set_label_list(en: 'Secured Asset Investment Loan', es: 'Préstamo de Inversión de Bienes Asegurados')


      project_type = OptionSet.find_or_create_by(
          division: ::Division.root, model_type: ::Loan.name, model_attribute: 'project_type')
      project_type.options.destroy_all

      project_type.create_option(value: 'conversion').set_label_list(en: 'Conversion', es: 'TODO')
      project_type.create_option(value: 'expansion').set_label_list(en: 'Expansion', es: 'TODO')
      project_type.create_option(value: 'startup').set_label_list(en: 'Start-up', es: 'TODO')


      public_level = OptionSet.find_or_create_by(
          division: ::Division.root, model_type: ::Loan.name, model_attribute: 'public_level')
      public_level.options.destroy_all
      public_level.create_option(value: 'featured').set_label_list(en: 'Featured', es: 'TODO')
      public_level.create_option(value: 'hidden').set_label_list(en: 'Hidden', es: 'TODO')


      step_type = OptionSet.find_or_create_by(
          division: ::Division.root, model_type: ::ProjectStep.name, model_attribute: 'step_type')
      step_type.options.destroy_all
      step_type.create_option(value: 'step').set_label_list(en: 'Step', es: 'Paso')
      step_type.create_option(value: 'milestone').set_label_list(en: 'Milestone', es: 'TODO')
      # legacy data exists of type 'Agenda', but not expecting to carry this forward into the new system
      # step_type.create_option(value: 'agenda').set_label_list(en: 'Agenda', es: 'TODO')


      progress_metric = OptionSet.find_or_create_by(
          division: ::Division.root, model_type: ::ProjectLog.name, model_attribute: 'progress_metric')
      progress_metric.options.destroy_all
      progress_metric.create_option(migration_id: -3).
          set_label_list(en: 'in need of changing its whole plan', es: 'con necesidad de cambiar su plan completamente')
      progress_metric.create_option(migration_id: -2).
          set_label_list(en: 'in need of changing some events', es: 'con necesidad de cambiar algunos eventos')
      progress_metric.create_option(migration_id: -1).set_label_list(en: 'behind', es: 'atrasado')
      progress_metric.create_option(migration_id: 1).set_label_list(en: 'on time', es: 'a tiempo')
      progress_metric.create_option(migration_id: 2).set_label_list(en: 'ahead', es: 'adelantado')


      CustomFieldSet.find_or_create_by(id: 2, division: Division.root, internal_name: 'loan_criteria').set_label('Loan Criteria Questionnaire')
      CustomFieldSet.find_or_create_by(id: 3, division: Division.root, internal_name: 'loan_post_analysis').set_label('Loan Post Analysis')
      CustomFieldSet.recalibrate_sequence(gap: 10)
      org_field_set = CustomFieldSet.find_or_create_by(division: Division.root, internal_name: 'Organization')
      org_field_set.custom_fields.destroy_all
      org_field_set.custom_fields.create!(internal_name: 'is_recovered', data_type: 'boolean')

    end


    # useful to remove the above data so that it can be re-run in isolation
    def self.purge
      Language.where("id > 2").destroy_all rescue nil
      Country.destroy_all rescue nil
      Currency.destroy_all rescue nil
      OptionSet.destroy_all rescue nil
    end

  end


end
