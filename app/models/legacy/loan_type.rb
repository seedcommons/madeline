# -*- SkipSchemaAnnotations
module Legacy
  class LoanType < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel

    def self.migrate_all
      puts "LoanTypes: #{ self.count }"
      self.all.each &:migrate
    end

    def self.purge_migrated
      puts "OptionSet.find_by(model_attribute: :loan_type).options.destroy_all"
      ::OptionSet.find_by(model_attribute: :loan_type).options.destroy_all
    end

    def migrate
      data = migration_data
      # puts "#{data[:id]}: #{data[:url]}"
      translations = data.delete(:translations)
      record = ::Option.new(data)
      translations.each do |k, v|
        attribute = k.to_s.sub(/_(\w\w)$/, '')
        locale = $1
        record.set_translation(attribute, v, locale: locale)
      end
      record.save!
    end

    def migration_data
      data = {
        migration_id: id,
        option_set_id: 2, # loan_type
        translations: {
          label_en: english_name,
          label_es: spanish_name,
          description_en: english_description,
          description_es: spanish_description,
        }
      }
      data
    end

    def option_id_for_loan_type(loan_type_id)
      DueDiligencePerLoanType.loan_type_option_set.value_for_migration_id(loan_type_id)
    end

  end
end
