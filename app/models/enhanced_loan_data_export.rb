class EnhancedLoanDataExport < StandardLoanDataExport

  protected

  def object_data_as_hash(loan)
    super.merge(response_hash(loan))
  end

  # We index questions by ID in this hash but use question labels in the header row.
  def response_hash(loan)
    result = {}
    response_sets = ResponseSet.joins(:question_set).where(loan: loan).order("question_sets.kind")
    response_sets.each do |response_set|
      response_set.custom_data.each do |q_id, response_data|
        question = questions_by_id[q_id.to_i]
        if question.present?
          response = Response.new(loan: loan, question: question,
                                  response_set: response_set, data: response_data)

          # Note, this approach will exclude parts of compound data types, such as `range`,
          # which can have both a `rating` and a `text` component.
          # `url`, `start_cell`, and `end_cell` components from questions with `has_embeddable_media`=true
          # are also not included, nor are `business_canvas`, and `breakeven`, which would be way too big
          # to put in a CSV cell.
          result[q_id.to_i] =
            if response.not_applicable?
              ""
            elsif response.has_rating?
              response.rating
            elsif response.has_number?
              include_numeric_answer_in_export?(response.number) ? response.number : ""
            elsif response.has_boolean?
              response.boolean
            elsif response.has_text?
              response.text
            end
        end
      end
    end
    result
  end

  def include_numeric_answer_in_export?(str)
    true #include all numeric answers, even if invalid text
  end

  def q_data_types
    ["boolean", "text", "number", "percentage", "rating", "currency", "range"]
  end

  def header_rows
    [main_header_row, question_id_row]
  end

  def main_header_row
    headers = StandardLoanDataExport::HEADERS.map { |h| I18n.t("standard_loan_data_exports.headers.#{h}") }
    headers + questions.map { |q| q.label.to_s }
  end

  def question_id_row
    row = [I18n.t("standard_loan_data_exports.headers.question_id")]
    row[StandardLoanDataExport::HEADERS.size - 1] = nil
    row + questions.map(&:id)
  end

  # Returns questions in the order we want them to show up in the header row.
  # Includes question sets from target division and all its descendants.
  def questions
    @questions ||= question_sets.flat_map do |question_set|
      question_set.root_group.self_and_descendants_preordered.select do |q|
        q_data_types.include?(q.data_type)
      end
    end
  end

  def question_sets
    # We want self to come first for deterministic behavior in specs. After that it doesn't really matter.
    # self_and_descendants orders by depth so we are good.
    division.self_and_descendants.flat_map { |d| QuestionSet.where(division: d).order(:kind).to_a }
  end

  def questions_by_id
    @questions_by_id ||= questions.index_by(&:id)
  end

  # Returns the list of symbols representing headers in the order they should appear.
  def header_symbols
    @header_symbols ||= StandardLoanDataExport::HEADERS + questions.map(&:id)
  end
end
