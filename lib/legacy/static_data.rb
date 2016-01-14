module Legacy

  class StaticData

    def self.populate

      # The EN and ES Languages are expected to be already populated by seeds.rb
      Language.find_or_create_by(id: 1, name: 'English', code: 'EN')
      Language.find_or_create_by(id: 2, name: 'Español', code: 'ES')

      Language.find_or_create_by(id: 3, name: 'Français', code: 'FR')
      Language.connection.execute("select setval('languages_id_seq', (select max(id) from languages))")


      Currency.find_or_create_by(id: 1, name: 'Argentinean Peso', code: 'ARS', symbol: 'AR$')
      Currency.find_or_create_by(id: 2, name: 'U.S. Dollar', code: 'USD', symbol: 'US$')
      Currency.find_or_create_by(id: 3, name: 'British Pound', code: 'GBP', symbol: 'GB£')
      Currency.find_or_create_by(id: 4, name: 'Nicaraguan Cordoba', code: 'NIO', symbol: 'NI$')
      Currency.connection.execute("select setval('currencies_id_seq', (select max(id) from currencies))")


      Country.find_or_create_by(id: 1, name: 'Argentina', iso_code: 'AR', default_language_id: 2, default_currency_id: 1)
      Country.find_or_create_by(id: 2, name: 'Nicaragua', iso_code: 'NI', default_language_id: 2, default_currency_id: 4)
      Country.find_or_create_by(id: 3, name: 'United States', iso_code: 'US', default_language_id: 1, default_currency_id: 2)
      Country.connection.execute("select setval('countries_id_seq', (select max(id) from countries))")


      # The option set and the first two options are expected to be already populated by seeds.rb
      loan_status = OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'status')
      option = loan_status.options.find_or_create_by(value: 'active')
      option.update(position: 1, migration_id: 1)
      option.set_label_list(en: 'Active', es: 'Prestamo Activo')
      option = loan_status.options.find_or_create_by(value: 'completed')
      option.update(position: 2, migration_id: 2)
      option.set_label_list(en: 'Completed', es: 'Prestamo Completo')

      loan_status.create_option(value: 'frozen', position: 3, migration_id: 3).
          set_label_list(en: 'Frozen', es: 'Prestamo Congelado')

      loan_status.create_option(value: 'liquidated', position: 4, migration_id: 4).
          set_label_list(en: 'Liquidated', es: 'Prestamo Liquidado')

      loan_status.create_option(value: 'prospective', position: 5, migration_id: 5).
          set_label_list(en: 'Prospective', es: 'Prestamo Prospectivo')

      loan_status.create_option(value: 'refinanced', position: 6, migration_id: 6).
          set_label_list(en: 'Refinanced', es: 'Prestamo Refinanciado')

      loan_status.create_option(value: 'relationship', position: 7, migration_id: 7).
          set_label_list(en: 'Relationship', es: 'Relacion')

      loan_status.create_option(value: 'relationship_active', position: 8, migration_id: 8).
          set_label_list(en: 'Relationship Active', es: 'Relacion Activo')


      # Note, the option sets are expected to be included in seeds.rb
      loan_type = OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'loan_type')

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


      project_type = OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'project_type')

      project_type.create_option(value: 'conversion', migration_id: 1).
          set_label_list(en: 'Conversion', es: 'TODO')

      project_type.create_option(value: 'expansion', migration_id: 2).
          set_label_list(en: 'Expansion', es: 'TODO')

      project_type.create_option(value: 'startup', migration_id: 3).
          set_label_list(en: 'Start-up', es: 'TODO')


      public_level = OptionSet.find_or_create_by(division: ::Division.root, model_type: ::Loan.name, model_attribute: 'public_level')

      public_level.create_option(value: 'featured', migration_id: 1).
          set_label_list(en: 'Featured', es: 'TODO')

      public_level.create_option(value: 'hidden', migration_id: 2).
          set_label_list(en: 'Hidden', es: 'TODO')



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
