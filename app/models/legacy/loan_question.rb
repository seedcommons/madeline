# -*- SkipSchemaAnnotations
module Legacy

  class LoanQuestion < ApplicationRecord
    establish_connection :legacy
    include LegacyModel

    self.primary_key = "id"

    def self.migrate_all
      puts "---------------------------------------------------------"
      puts "Migrating question set Criteria"
      question_set = QuestionSet.create!(division_id: 2, kind: "loan_criteria")
      migrate_questions(active: 2, group_id: nil, question_set: question_set)

      puts "---------------------------------------------------------"
      puts "Migrating question set Post Analysis"
      question_set = QuestionSet.create!(division_id: 2, kind: "loan_post_analysis")
      migrate_questions(active: 3, group_id: nil, question_set: question_set)

      Question.rebuild! # Fix hierarchies table since we did manual inserts.
    end

    def self.migrate_questions(active:, group_id:, question_set:)
      position = -1
      where(active: active, grupo: group_id).order(:orden).each do |old_question|
        position += 1
        old_question.migrate(question_set: question_set, position: position)
        if old_question.data_type == "group"
          migrate_questions(active: active, group_id: old_question.id, question_set: question_set)
        elsif (children = where(active: active, grupo: old_question.id)).any?
          children.each do |question|
            Migration.log << ["LoanQuestion", question.id, "Not migrating because parent is not a group"]
          end
        end
      end
    end

    def migrate(question_set:, position:)
      data = migration_data(question_set: question_set, position: position)
      pp data
      # Using insert because otherwise positions get messed up.
      question_id = Question.insert(data.without(:label_en, :label_es))[0]["id"]
      question = Question.find(question_id)

      # Migrate translations
      question.update!(data.slice(:label_en, :label_es))

      create_loan_question_requirements(question) if question.parent.root?
    end

    def data_type
      # These two are stored as groups in the old system but are definitely not groups.
      return "text" if type.blank? || [45, 117].include?(id)

      DATA_TYPE_MAP[type]
    end

    private

    def migration_data(question_set:, position:)
      {
        legacy_id: id,
        question_set_id: question_set.id,
        position: position,
        number: position + 1,
        division_id: 2,
        parent_id: grupo.present? ? Question.find_by!(legacy_id: grupo).id : question_set.root_group.id,
        data_type: data_type,
        has_embeddable_media: (i_frame == 1),
        label_es: question || "",
        label_en: question_en || "",
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    def create_loan_question_requirements(question)
      OptionSet.find_by(model_attribute: "loan_type").options.pluck(:id).each do |opt_id|
        question.loan_question_requirements.create!(option_id: opt_id)
      end
    end

    DATA_TYPE_MAP = {
      "Texto Breve" => "string",
      "Texto Grande" => "text",
      "Numero" => "number",
      "Rango" => "range",
      "Grupo" => "group"
    }
  end
end
