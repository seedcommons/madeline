# -*- SkipSchemaAnnotations
module Legacy

  class LoanQuestion < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel


    remove_method :id, :question

    def migration_data
      data = {
          id: id,
          custom_field_set_id: active,
          position: orden,
          parent_id: grupo,
          data_type: data_type,
          label: question
      }
      data
    end

    def migrate
      data = migration_data
      puts "#{data[:id]}: #{data[:label]}"
      label = data.delete(:label)
      model = ::CustomField.create(data)
      # model.set_label(label, language: :es)
      model.set_label(label, :es)
    end


    def self.migrate_all
      puts "loan questions: #{ self.count }"
      self.all.each &:migrate
      # self.all.each &:migrate
      ::CustomField.recalibrate_sequence(gap: 100)
    end

    def self.purge_migrated
      puts "CustomField.destroy_all"
      ::CustomField.where("custom_field_set_id < 4").destroy_all
    end


    def data_type
      #todo: how to best handle IFrame flag?
      DATA_TYPE_MAP[type]
    end

    DATA_TYPE_MAP = {
        'Texto Breve' => 'string',
        'Texto Grande' => 'text',
        'Numero' => 'number',
        'Rango' => 'range',
        'Grupo' => 'group'
    }

  end

end
