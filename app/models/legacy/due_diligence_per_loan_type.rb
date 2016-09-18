#
# Maps to LoanQuestionRequirement in new schema

# -*- SkipSchemaAnnotations
module Legacy
  class DueDiligencePerLoanType < ActiveRecord::Base
    establish_connection :legacy

    # This new table didn't follow the pluralization convention used by the other mysql tables,
    # so need to override here before the 'include LegacyModel'.
    self.table_name = 'DueDiligencePerLoanType'
    include LegacyModel

    def self.migrate_all
      puts "DueDiligencePerLoanType: #{ self.count }"
      self.all.each &:migrate
    end

    def self.purge_migrated
      puts "LoanQuestionRequirement.destroy_all"
      ::LoanQuestionRequirement.destroy_all
    end

    def self.loan_type_option_set
      @loan_type_option_set ||= OptionSet.fetch(::Loan, 'loan_type')
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:url]}"
      ::LoanQuestionRequirement.create(data)
    end

    def migration_data
      data = {
          custom_field_id: due_diligence_id,
          option_id: option_id_for_loan_type(loan_type_id),
          amount: amount
      }
      data
    end

    def option_id_for_loan_type(loan_type_id)
      DueDiligencePerLoanType.loan_type_option_set.value_for_migration_id(loan_type_id)
    end

  end
end
