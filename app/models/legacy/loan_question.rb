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
      ::Question.recalibrate_sequence
      ::LoanQuestionSet.create_root_groups!
    end

    def self.migrate_set(set_id)
      where("Active = :set_id and NewGroup is null", {set_id: set_id}).  # Root nodes
        order('NewOrder').each do |record|
        record.migrate
      end
    end

    def self.purge_migrated
      puts "LoanQuestion.destroy_all"
      ::Question.where("loan_question_set_id <= 4").destroy_all
    end

    def parent_id
      new_group
    end

    def position
      new_order
    end

    def migration_data
      status = :active
      loan_question_set_id = active
      # question question sets 1 & 2 will now be considered 'inactive'
      status = :inactive if active <= 2
      status = :retired if new_order.blank? || new_order == 0
      # questions sets 1,2 & 4 will all map now to 'criteria'
      loan_question_set_id = (active == 3) ? 3 : 2

      data = {
        id: id,
        internal_name: "field_#{id}",
        loan_question_set_id: loan_question_set_id,
        status: status,
        position: position,
        migration_position: position,
        parent_id: parent_id,
        required: (required == 1),
        data_type: data_type,
        has_embeddable_media: (i_frame == 1),
        label_es: question,
        label_en: question_en
      }
      data
    end

    def migrate
      # Assuming that source data will be manually cleaned up before final migration.
      # if grupo.blank? && data_type != 'group'
      #   puts "skipping loan question without parent but not a group type - id: #{id}"
      #   return
      # end
      # if orden.blank? || orden == 0
      #   puts "skipping loan question with 0 Orden - id: #{id}"
      #   return
      # end
      # if LoanQuestion.where("Active = :active and Orden = :orden and Grupo = :grupo and id > :id",
      #   {active: active, orden: orden, grupo: grupo, id: id}).exists?
      #   puts "skipping loan question shadowed by same Orden value - id: #{id}"
      #   return
      # end

      data = migration_data
      # puts "#{data[:id]}: #{data[:label_es]}"
      label_es = data.delete(:label_es)
      label_en = data.delete(:label_en)
      model = ::Question.new(data)
      model.set_translation(:label, label_es, locale: :es) if label_es.present?
      model.set_translation(:label, label_en, locale: :en) if label_en.present?
      model.save!

      migrate_children if data_type == 'group'
    end

    def migrate_children
      LoanQuestion.where("NewGroup = :parent_id",
        {parent_id: id}).order('NewOrder').each do |record|
        record.migrate
      end
    end

    def data_type
      #todo: how to best handle IFrame flag?
      type_key = self.type
      type_key = 'Texto Grande' if type_key.blank?
      DATA_TYPE_MAP[type_key]
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
