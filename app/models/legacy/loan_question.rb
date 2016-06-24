# -*- SkipSchemaAnnotations
module Legacy

  class LoanQuestion < ActiveRecord::Base
    establish_connection :legacy
    include LegacyModel

    remove_method :id, :question

    def self.migrate_all
      puts "loan questions: #{ self.count }"
      (1..4).each{ |set_id| migrate_set(set_id) }
      # self.all.each &:migrate
      ::CustomField.recalibrate_sequence(gap: 100)
    end

    def self.migrate_set(set_id)
      where("Active = :set_id and Orden > 0 and Grupo is null", {set_id: set_id}).
        order(:orden).each do |record|
        record.migrate
      end
    end

    def self.purge_migrated
      puts "CustomField.destroy_all"
      ::CustomField.where("custom_field_set_id < 4").destroy_all
    end


    def migration_data
      data = {
        id: id,
        internal_name: "field_#{id}",
        custom_field_set_id: active,
        position: orden,
        migration_position: orden,
        parent_id: grupo,
        required: (required == 1),
        data_type: data_type,
        has_embeddable_media: (i_frame == 1),
        label_es: question,
        label_en: question_en
      }
      data
    end

    def migrate
      if grupo.blank? && data_type != 'group'
        puts "skipping loan question without parent but not a group type - id: #{id}"
        return
      end
      if orden.blank? || orden == 0
        puts "skipping loan question with 0 Orden - id: #{id}"
        return
      end
      if LoanQuestion.where("Active = :active and Orden = :orden and Grupo = :grupo and id > :id",
        {active: active, orden: orden, grupo: grupo, id: id}).exists?
        puts "skipping loan question shadowed by same Orden value - id: #{id}"
        return
      end

      data = migration_data
      puts "#{data[:id]}: #{data[:label_es]}"
      label_es = data.delete(:label_es)
      label_en = data.delete(:label_en)
      model = ::CustomField.new(data)
      model.set_translation(:label, label_es, locale: :es) if label_es.present?
      model.set_translation(:label, label_en, locale: :en) if label_en.present?
      model.save!

      migrate_children if data_type == 'group'
    end

    def migrate_children
      LoanQuestion.where("Active = :active and Grupo = :grupo",
        {active: active, grupo: id}).order(:orden).each do |record|
        record.migrate
      end
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
