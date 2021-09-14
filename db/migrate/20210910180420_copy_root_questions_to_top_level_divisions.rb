class CopyRootQuestionsToTopLevelDivisions < ActiveRecord::Migration[6.1]
  ATTR_NAMES = %w(active created_at data_type display_in_summary has_embeddable_media
                  internal_name override_associations)

  def up
    root_division = Division.root
    QuestionSet::KINDS.each do |kind|
      src_qset = QuestionSet.find_by(division: root_division, kind: kind)
      Division.where(parent_id: root_division.id).find_each do |dest_division|
        unless division_or_descendants_have_response_sets_for_question_set?(dest_division, src_qset)
          say "Division #{dest_division.id} has no response sets for #{kind}, skipping"
          next
        end
        copy_qset_to_division(src_qset, dest_division)
      end
      src_qset.destroy
    end
  end

  private

  def division_or_descendants_have_response_sets_for_question_set?(division, qset)
    descendant_div_ids = division.self_and_descendants.pluck(:id)
    ResponseSet.joins(:loan).where(question_set: qset, projects: {division_id: descendant_div_ids}).any?
  end

  def copy_qset_to_division(src_qset, dest_division)
    id_map = {}
    dest_qset = QuestionSet.create!(division: dest_division, kind: src_qset.kind)
    say "Copying question set #{src_qset.kind} to division #{dest_division.id}"
    id_map[[dest_division.id, src_qset.root_group.id]] = dest_qset.root_group.id
    copy_group_to_division(src_qset.root_group_including_tree, dest_qset, dest_division, id_map)
    update_response_sets(dest_division, src_qset, dest_qset, id_map)
  end

  def copy_group_to_division(src_group, dest_qset, dest_division, id_map)
    src_group.children.each do |src_question|
      if !question_is_in_ancestor_or_descendant_division?(src_question, dest_division)
        say "Skipping question or group #{src_question.id} since its division #{src_question.division_id} "\
          "is neither the current division, nor an ancestor or descendant of the current division."
        next
      end
      dest_question = copy_question_to_qset(dest_qset, dest_division, src_question, id_map)
      copy_question_translations(src_question, dest_question)
      copy_group_to_division(src_question, dest_qset, dest_division, id_map) if src_question.group?
    end
  end

  def copy_question_to_qset(dest_qset, dest_division, src_question, id_map)
    say "Copying question or group #{src_question.id} to division #{dest_division.id}"
    attribs = build_question_attribs(dest_qset, dest_division, src_question, id_map)
    dest_question = Question.create!(attribs)
    copy_question_translations(src_question, dest_question)
    copy_question_requirements(src_question, dest_question)
    id_map[[dest_division.id, src_question.id]] = dest_question.id
    dest_question
  end

  def build_question_attribs(dest_qset, dest_division, src_question, id_map)
    attribs = src_question.attributes.slice(*ATTR_NAMES)
    attribs["parent_id"] = id_map[[dest_division.id, src_question.parent_id]]

    if attribs["parent_id"].nil? && !src_question.parent_id.nil?
      raise "Question #{src_question.id} has a parent but parent_id not found in ID map"
    end

    # We are moving root questions to first level divisions.
    attribs["division_id"] = src_question.division.root? ? dest_division.id : src_question.division_id

    attribs["question_set_id"] = dest_qset.id
    attribs["migration_position"] = src_question.id # Saving this just in case.
    attribs
  end

  def copy_question_translations(src_question, dest_question)
    query = <<~SQL
      INSERT INTO translations (locale, text, translatable_type, translatable_attribute,
        translatable_id, allow_html, created_at, updated_at)
        SELECT locale, text, translatable_type, translatable_attribute, #{dest_question.id},
          allow_html, created_at, updated_at
          FROM translations
          WHERE translatable_type = 'Question' AND translatable_id = #{src_question.id}
    SQL
    execute(query)
  end

  def copy_question_requirements(src_question, dest_question)
    query = <<~SQL
      INSERT INTO loan_question_requirements (amount, option_id, question_id)
        SELECT amount, option_id, #{dest_question.id}
        FROM loan_question_requirements
        WHERE question_id = #{src_question.id}
    SQL
    execute(query)
  end

  def question_is_in_ancestor_or_descendant_division?(src_question, dest_division)
    src_division = src_question.division
    return true if src_division.self_or_ancestor_of?(dest_division)
    return true if src_division.self_or_descendant_of?(dest_division)

    false
  end

  def update_response_sets(dest_division, src_qset, dest_qset, id_map)
    # We want response sets connected to all loans from dest_division and all its descendants
    descendant_div_ids = dest_division.self_and_descendants.pluck(:id).join(",")
    chunks = id_map.map { |pair, dest_id| "jsonb_build_object('#{dest_id}', custom_data->'#{pair[1]}')" }
    query = "UPDATE response_sets SET "\
      "question_set_id = #{dest_qset.id}, "\
      "custom_data = #{chunks.join(' || ')} "\
      "WHERE (SELECT division_id FROM projects WHERE id = response_sets.loan_id) IN (#{descendant_div_ids}) "\
        "AND question_set_id = #{src_qset.id}"
    execute(query)
  end
end
